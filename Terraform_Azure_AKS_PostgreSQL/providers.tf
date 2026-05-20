terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

# Key Vault is deployed to a separate subscription
provider "azurerm" {
  alias           = "kv_sub"
  subscription_id = "903ad9f0-00e9-470f-9a53-d430f73dcd0d"
  features {}
}
