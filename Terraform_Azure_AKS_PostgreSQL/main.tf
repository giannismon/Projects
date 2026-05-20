data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "random_password" "postgres" {
  length           = 20
  special          = true
  override_special = "!#$%&*-_=+"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}"
  location = var.location
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-${var.prefix}-cluster"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "id-${var.prefix}-app"
  location            = azurerm_resource_group.main.location
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
  app_identity_principal_id = azurerm_user_assigned_identity.app.principal_id
  postgres_password         = random_password.postgres.result
}

module "postgres" {
  source = "./modules/postgres"

  prefix              = var.prefix
  suffix              = random_string.suffix.result
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.network.postgres_subnet_id
  private_dns_zone_id = module.network.postgres_dns_zone_id
  password            = random_password.postgres.result
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.prefix}"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  default_node_pool {
    name           = "system"
    node_count     = 2
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = module.network.aks_subnet_id
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }
}
