# Terraform Azure AGW + VM

Deploys a production-ready Azure infrastructure using Terraform modules, supporting both **QA** and **PROD** environments. The setup includes an Application Gateway (WAF_v2) as a reverse proxy in front of a Windows/Linux VM, secured with Azure Bastion for private access, Key Vault for secret management, and a WAF Policy for IP blocking and OWASP protection.

## Architecture

```
tf-azure-local/
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
2. **Key Vault** + **Networking** — parallel, no dependency between them
3. **Virtual Machine** — requires VM subnet (networking) and password (Key Vault)
4. **Managed Disks (x2)** — parallel, attached to the VM after it is created
5. **Application Gateway (WAF_v2)** — requires AGW subnet and VM private IP
6. **Azure Bastion** — requires the Bastion subnet

## Infrastructure Components

| Module | Resource | Description |
|---|---|---|
| `rg` | Resource Group | Groups all resources per environment |
| `keyvault` | Key Vault | Stores and retrieves VM credentials |
| `networking` | VNet + 3 Subnets | VM subnet, AGW subnet, Bastion subnet |
| `vm` | Virtual Machine | Application server in private subnet, no public IP |
| `disk` | Managed Disk (x2) | Additional data disks attached to the VM |
| `agw` | Application Gateway WAF_v2 + WAF Policy | Public-facing reverse proxy with IP blocking and OWASP 3.2 rules |
| `bastion` | Azure Bastion | Secure RDP/SSH access without public IP |

## Security

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
