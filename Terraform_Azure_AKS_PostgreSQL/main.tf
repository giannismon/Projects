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

resource "azurerm_user_assigned_identity" "app" {
  name                = "id-app-${var.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.prefix}-${random_string.suffix.result}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization  = false
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "Set", "Delete", "List", "Purge", "Recover"]
  }

  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = azurerm_user_assigned_identity.app.principal_id
    secret_permissions = ["Get", "List"]
  }
}

resource "azurerm_key_vault_secret" "my_secret" {
  name         = "my-secret"
  value        = "value_1"
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_kubernetes_cluster" "main" {
  name                      = "aks-${var.prefix}"
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  dns_prefix                = "aks-${var.prefix}"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
  }

  network_profile {
    network_plugin = "kubenet"
  }
}

# Links the AKS OIDC issuer to the managed identity for the app-sa service account
resource "azurerm_federated_identity_credential" "app" {
  name                = "fed-app-${var.prefix}"
  resource_group_name = azurerm_resource_group.main.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.app.id
  subject             = "system:serviceaccount:default:app-sa"
}
