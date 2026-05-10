# Terraform Azure AGW + VM

Deploys a production-ready Azure infrastructure using Terraform modules, supporting both **QA** and **PROD** environments. The setup includes an Application Gateway as a reverse proxy in front of a Windows/Linux VM, secured with Azure Bastion for private access and Key Vault for secret management.

## Architecture

```
tf-azure-local/
├── envs/
│   ├── qa/
│   │   ├── main.tf          ← Provider + modules + VNet + Subnets
│   │   ├── variables.tf     ← Variable definitions for QA
│   │   ├── terraform.tfvars ← QA values (edit this)
│   │   └── outputs.tf       ← IPs after apply
│   └── prod/
│       ├── main.tf          ← same as qa
│       ├── variables.tf     ← Variable definitions for PROD
│       ├── terraform.tfvars ← PROD values (edit this)
│       └── outputs.tf       ← IPs after apply
└── modules/
    ├── rg/                  ← Resource Group
    ├── keyvault/            ← Key Vault + Secret
    ├── vm/                  ← NIC + VM
    ├── disk/                ← Managed Disk + Attachment
    ├── agw/                 ← Public IP + Application Gateway
    └── bastion/             ← Public IP + Bastion Host
```

## Infrastructure Components

| Module | Resource | Description |
|---|---|---|
| `rg` | Resource Group | Groups all resources per environment |
| `vm` | Windows/Linux VM | Application server in private subnet |
| `disk` | Managed Disk | Additional data disks attached to VM |
| `agw` | Application Gateway | Public-facing reverse proxy |
| `bastion` | Azure Bastion | Secure private access to VM |
| `keyvault` | Key Vault | Stores and retrieves VM credentials |

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

## Requirements

- Terraform >= 1.0
- Azure CLI authenticated (`az login`)
- Azure subscription with Contributor access
- AzureRM provider `~> 3.0`
