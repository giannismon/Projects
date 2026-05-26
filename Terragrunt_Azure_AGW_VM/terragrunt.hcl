locals {
  env = basename(dirname(get_terragrunt_dir()))
}

remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "mytfstate"
    container_name       = "tfstate"
    key                  = "${local.env}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-PROVIDER
    terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 3.0"
        }
      }
    }
    provider "azurerm" {
      features {
        key_vault {
          purge_soft_delete_on_destroy = true
        }
      }
    }
  PROVIDER
}
