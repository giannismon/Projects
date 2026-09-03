# Projects

A collection of DevOps and automation scripts.

| Project | Description |
|---|---|
| [Trigger Azure Pipeline from VM](./Trigger_Azure_Pipeline_from_VM) | Monitors a URL every minute and auto-triggers an Azure DevOps pipeline to restart a service on failure, with a 2-hour cooldown |
| [Terraform Azure AGW + VM](./Terraform_Azure_AGW_VM) | Deploys Azure infrastructure (Application Gateway, VM, Bastion, Key Vault) with Terraform modules for QA and PROD environments |
| [Terragrunt Azure AGW + VM](./Terragrunt_Azure_AGW_VM) | Deploys Azure infrastructure (Application Gateway, VM, Bastion, Key Vault) with Terragrunt DRY configs for QA and PROD environments |
| [Terraform Azure AKS](./Terraform_Azure_AKS) | Deploys an AKS cluster with Terraform — cluster in the environment root, user node pools through a reusable module with for_each, cluster autoscaler and managed identity |
