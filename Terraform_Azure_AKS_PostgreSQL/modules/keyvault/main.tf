terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.prefix}-${var.suffix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization  = false
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.tf_principal_id

    secret_permissions = ["Get", "Set", "Delete", "List", "Purge", "Recover"]
  }

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.app_identity_principal_id

    secret_permissions = ["Get", "List"]
  }
}

resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-password"
  value        = var.postgres_password
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "vm_admin_password" {
  name         = "vm-admin-password"
  value        = var.vm_admin_password
  key_vault_id = azurerm_key_vault.main.id
}
