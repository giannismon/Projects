resource "azurerm_user_assigned_identity" "this" {
  name                = "id-app-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
}
