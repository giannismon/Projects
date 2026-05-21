data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}"
  location = var.location
}

module "identity" {
  source = "./modules/identity"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

module "network" {
  source = "./modules/network"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

module "keyvault" {
  source = "./modules/keyvault"

  prefix                    = var.prefix
  location                  = var.location
  suffix                    = random_string.suffix.result
  resource_group_name       = azurerm_resource_group.main.name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  tf_principal_id           = data.azurerm_client_config.current.object_id
  app_identity_principal_id = module.identity.principal_id
  secret_name               = "my-secret"
  secret_value              = "value_1"
}

module "aks" {
  source = "./modules/aks"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.network.aks_subnet_id
  app_identity_id     = module.identity.id
  app_sa_namespace    = "default"
  app_sa_name         = "app-sa"
}
