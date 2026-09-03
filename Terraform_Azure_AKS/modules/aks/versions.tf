# The module declares ONLY what it requires. The provider block belongs to the
# root module — otherwise this module cannot be reused with another
# subscription or provider alias.
terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
