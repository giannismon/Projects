# Terraform Azure AKS

Deploys an Azure Kubernetes Service cluster with Terraform. The cluster and its resource group live in the environment root; user node pools are created through a single reusable module, one call per pool.

Originally a hand-written `az aks create` script, rewritten so the environment can be reviewed before it changes, reproduced exactly, and torn down without leaving billable leftovers behind.

## Architecture

```
Terraform_Azure_AKS/
├── modules/
│   └── nodepool/               # one user node pool — the only module
│       ├── versions.tf
│       ├── variables.tf
│       ├── main.tf
│       └── outputs.tf
└── envs/
    └── dev/
        ├── versions.tf         # provider + backend
        ├── variables.tf
        ├── main.tf             # resource group, cluster, and for_each over the module
        ├── outputs.tf
        └── terraform.tfvars.example
```

A second environment is a copy of `envs/dev/` with its own `terraform.tfvars`, reusing the same module and keeping a separate state file.

## What it creates

| Resource | Where it is defined | Notes |
|---|---|---|
| Resource group `rg-<prefix>` | `envs/dev/main.tf` | |
| AKS cluster `aks-<prefix>` | `envs/dev/main.tf` | `Free` SKU, Azure CNI, system-assigned identity |
| System node pool | `default_node_pool` block | autoscaling, runs CoreDNS and metrics-server |
| User node pools | `modules/nodepool` | one module instance per map key |

Tags are applied to the resources and reused as node labels, so `kubectl get nodes -L owner,env` identifies node ownership without opening the portal.

### Why the system pool is not a module

`default_node_pool` is a block inside the `azurerm_kubernetes_cluster` resource, not a standalone resource — Azure requires it to exist from the moment the cluster is created. Only user pools are separate resources, so only they can be modularised.

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

Each key becomes its own module instance, addressed as `module.node_pool["dbpool"]`. Because `for_each` tracks pools by key rather than by list index, removing one pool leaves the others untouched.

## Design notes

**`ignore_changes` on `node_count`** — set on both the system pool and the module. Node count is owned by the cluster autoscaler at runtime; without this, an unrelated `terraform apply` would reset the count and destroy nodes that are actively running pods.

**No provider block in the module** — a module that declares its own provider cannot be reused with a different subscription or alias, and produces a deprecation warning.

**Node pool name validation** — the module rejects names Azure would refuse (lowercase, alphanumeric, max 12 characters for Linux pools) at plan time rather than eight minutes into an apply.

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
