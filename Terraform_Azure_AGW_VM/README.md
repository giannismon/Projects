# Terraform Azure AGW + VM

Deploys a production-ready Azure infrastructure using Terraform modules, supporting both **QA** and **PROD** environments. The setup includes an Application Gateway as a reverse proxy in front of a Windows/Linux VM, secured with Azure Bastion for private access and Key Vault for secret management.

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
2. **Key Vault** — stores the VM admin password
3. **Networking** — VNet and 3 subnets (VM, AGW, Bastion)
4. **Virtual Machine** — uses the VM subnet and retrieves password from Key Vault
5. **Managed Disks (x2)** — attached to the VM after it is created
6. **Application Gateway** — requires the AGW subnet and VM private IP
7. **Azure Bastion** — requires the Bastion subnet

## Infrastructure Components

| Module | Resource | Description |
|---|---|---|
| `rg` | Resource Group | Groups all resources per environment |
| `networking` | VNet + Subnets | Virtual network and 3 subnets (VM, AGW, Bastion) |
| `keyvault` | Key Vault | Stores and retrieves VM credentials |
| `vm` | Windows/Linux VM | Application server in private subnet |
| `disk` | Managed Disk | Additional data disks attached to VM |
| `agw` | Application Gateway | Public-facing reverse proxy |
| `bastion` | Azure Bastion | Secure private access to VM |

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

