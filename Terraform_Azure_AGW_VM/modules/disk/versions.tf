terraform {
  required_version = ">= 1.3" # optional() with a default value in an object type

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
