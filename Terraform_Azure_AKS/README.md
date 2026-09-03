# Terraform Azure AKS

Deploys an Azure Kubernetes Service cluster with Terraform, split into a reusable module and per-environment value files. The cluster runs a system node pool plus any number of user node pools, all with the cluster autoscaler enabled and a managed identity.

Originally a hand-written `az aks create` script, rewritten so the environment can be reviewed before it changes, reproduced exactly, and torn down without leaving billable leftovers behind.

## Architecture

```
Terraform_Azure_AKS/
├── modules/
│   └── aks/                    # what an AKS cluster is — no values inside
│       ├── versions.tf
│       ├── variables.tf
│       ├── main.tf
│       └── outputs.tf
└── envs/
    └── dev/                    # how we want it in dev
        ├── versions.tf         # provider + backend
        ├── variables.tf
        ├── main.tf             # calls the module
        ├── outputs.tf
        └── terraform.tfvars.example
```

The module contains no environment values — no names, no region, no subscription. A second environment is a copy of `envs/dev/` with a different `terraform.tfvars`, reusing the same module and keeping its own state file.

## What it creates

| Resource | Name | Notes |
|---|---|---|
| Resource group | `rg-<prefix>` | |
| AKS cluster | `aks-<prefix>` | `Free` SKU, Azure CNI, system-assigned identity |
| System node pool | configurable | autoscaling, runs CoreDNS and metrics-server |
| User node pools | one per map key | autoscaling, `mode = User`, custom labels and taints |

Tags are applied to the resources and reused as node labels, so `kubectl get nodes -L owner,env` identifies node ownership without opening the portal.

## Usage

```bash
az login
az account set --subscription "<your subscription>"

cd envs/dev
cp terraform.tfvars.example terraform.tfvars   # then fill in subscription_id
terraform init
terraform plan -out=tfplan
terraform apply tfplan                          # 10-15 minutes
```

Connect to the cluster:

```bash
terraform output -raw get_credentials_command   # prints the az command
kubectl get nodes -L owner,env,type
```

Tear down:

```bash
terraform destroy
```

## Adding a node pool

No code changes — one more key in the map:

```hcl
user_node_pools = {
  apppool = { node_labels = { type = "app" } }
  dbpool  = { vm_size = "Standard_D4s_v3", node_labels = { type = "db" } }
}
```

The module uses `for_each`, so pools are tracked by key rather than by list index. Removing one pool therefore does not cause the others to be recreated.

## Design notes

**`ignore_changes` on `node_count`** — both pools set it. Node count is owned by the cluster autoscaler at runtime; without this, an unrelated `terraform apply` would reset the count and destroy nodes that are actively running pods.

**No provider block in the module** — a module that declares its own provider cannot be reused with a different subscription or alias, and produces a deprecation warning.

**`kube_config_raw` is marked sensitive** — otherwise `apply` prints the full kubeconfig to the console and into pipeline logs.

**`terraform.tfstate` is gitignored** — it stores the kubeconfig in plain text. For shared use, uncomment the `backend "azurerm"` block in `envs/dev/versions.tf` and run `terraform init -migrate-state`.

**`.terraform.lock.hcl` is committed** — it pins the provider version so everyone gets identical behaviour.

## Cost

Three `Standard_D2s_v3` nodes cost roughly €200/month. To pause without destroying:

```bash
az aks stop  --resource-group rg-<prefix> --name aks-<prefix>
az aks start --resource-group rg-<prefix> --name aks-<prefix>
```

While stopped, node VMs are not billed; managed disks and the public IP still are. Do not run `terraform apply` against a stopped cluster — Azure rejects most operations on it. A cluster left stopped for 12 months is deleted automatically.

## Requirements

- Terraform >= 1.6
- azurerm provider ~> 4.0
- Azure CLI, logged in with permission to create resource groups in the target subscription
