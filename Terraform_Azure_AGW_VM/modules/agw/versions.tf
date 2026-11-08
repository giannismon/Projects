terraform {
  required_version = ">= 1.3" # optional() με default τιμή σε object type

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
