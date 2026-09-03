terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Dev keeps state locally. As soon as a second person or a pipeline touches
  # this environment, uncomment the backend and run:
  #   terraform init -migrate-state
  #
  # backend "azurerm" {
  #   resource_group_name  = "rg-tfstate"
  #   storage_account_name = "sttfstateaksdev"
  #   container_name       = "tfstate"
  #   key                  = "aks/dev.tfstate"
  # }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
