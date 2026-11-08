# Terraform Azure AGW + VM

Deploys a production-ready Azure infrastructure using Terraform modules, supporting both **QA** and **PROD** environments. The setup includes an Application Gateway (WAF_v2) as a reverse proxy in front of a Windows/Linux VM, with HTTP → HTTPS redirect using a self-signed certificate stored in Key Vault, secured with Azure Bastion for private access, and a WAF Policy for IP blocking and OWASP protection.

## Architecture

```
Terraform_Azure_AGW_VM/
├── envs/
│   ├── qa/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── outputs.tf
└── modules/
    ├── rg/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── keyvault/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── networking/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── vm/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── disk/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── agw/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── bastion/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Deployment Order

Terraform creates resources in this order based on dependencies:

1. **Resource Group** — everything else depends on it
2. **User Assigned Identity** — created in env main.tf, needed by Key Vault and AGW
3. **Key Vault** + **Networking** — parallel; Key Vault depends on the identity's principal_id
4. **Virtual Machine** — requires VM subnet (networking) and password (Key Vault)
5. **Managed Disks (x2)** — parallel, attached to the VM after it is created
6. **Application Gateway (WAF_v2)** — requires AGW subnet, VM private IP, identity, and SSL cert from Key Vault
7. **Azure Bastion** — requires the Bastion subnet

## Infrastructure Components

| Module | Resource | Description |
|---|---|---|
| `rg` | Resource Group | Groups all resources per environment |
| *(env main.tf)* | User Assigned Identity | Grants AGW access to Key Vault certificates |
| `keyvault` | Key Vault + secrets & certificates (`for_each`) | Access policies, secrets and certificates come from maps |
| `networking` | VNet + Subnets (`for_each`) | Any number of subnets, keyed by logical name |
| `vm` | Virtual Machines (`for_each`) | Any number of VMs in the private subnet, no public IP |
| `disk` | Managed Disks (`for_each`) | Any number of data disks, each attached to a named VM |
| `agw` | Application Gateway WAF_v2 + WAF Policy | Public-facing reverse proxy with HTTPS termination, HTTP→HTTPS redirect, IP blocking, and OWASP 3.2 rules. Listeners, pools, rules, probes and WAF rules are all `dynamic` blocks driven by maps |
| `bastion` | Azure Bastion | Secure RDP/SSH access without public IP |

## Adding Resources

Every collection is a map keyed by a stable logical name, so adding infrastructure
means adding a map entry in `terraform.tfvars` — no `.tf` file is touched:

```hcl
vms = {
  app1 = {
    private_ip = "10.0.1.10"
    vm_size    = "Standard_B1s"
  }
  app2 = {
    private_ip = "10.0.1.11"
    vm_size    = "Standard_B2s"
  }
}

disks = {
  data = {
    vm           = "app1"
    disk_size_gb = 100
    lun          = 0
  }
  logs = {
    vm           = "app2"
    disk_size_gb = 50
    lun          = 0
  }
}
```

Maps are keyed on a logical name rather than indexed with `count`, so removing one
entry destroys only that resource instead of re-indexing everything after it. The key
is the identity in state: renaming a key means destroy and create.

`lun` is explicit per disk and must be unique **per VM** — deriving it from key order
would shift every other disk's `lun` when one is removed, re-attaching all of them.

Requires **Terraform >= 1.3** for optional object attributes with defaults.

Not every resource is a map: there is one resource group per environment (everything
hangs off it) and Azure allows only one Bastion host per VNet. Both modules take no
provider block, so the root can still call any of them with `for_each` if a second
one is ever needed.

## Security

### HTTPS Termination

The AGW terminates HTTPS using a self-signed certificate generated and stored in Key Vault:

- A **User Assigned Identity** is attached to the AGW and granted `Get` permission on Key Vault certificates and secrets
- Key Vault generates a **self-signed certificate** (RSA 2048, 12-month validity, auto-renew 30 days before expiry)
- The AGW references the certificate directly from Key Vault via its secret ID
- **Port 80 (HTTP)** performs a permanent `301` redirect to HTTPS — no content is served over plain HTTP
- **Port 443 (HTTPS)** terminates TLS and forwards traffic to the VM on port 80

### WAF Policy

The AGW runs as **WAF_v2** with a linked WAF Policy that provides:

- **Custom rule** — blocks specific IPs before they reach the AGW
- **OWASP 3.2 managed rules** — protects against SQL injection, XSS and other common attacks
- **Prevention mode** — blocks immediately, does not just log

IP blocking is handled at the WAF level because the VM never sees the original client IP — it only sees the AGW private IP. Blocking at NSG level on the VM subnet would have no effect.

## Environments

| Environment | VM Size | Disk Type |
|---|---|---|
| QA | `Standard_B1s` | `Standard_LRS` |
| PROD | `Standard_D2s_v3` | `Premium_LRS` |

## Setup

### 1. Set your Azure subscription

```bash
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
```

### 2. Configure variables

Edit `terraform.tfvars` in the desired environment and set:

```hcl
admin_password = "<YOUR_ADMIN_PASSWORD>"
```

### 3. Deploy QA

```bash
cd envs/qa/
terraform init
terraform plan
terraform apply -auto-approve
```

### 4. Deploy PROD

```bash
cd envs/prod/
terraform init
terraform plan
terraform apply -auto-approve
```
