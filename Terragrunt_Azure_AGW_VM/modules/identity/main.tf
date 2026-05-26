resource "azurerm_user_assigned_identity" "agw_identity" {
  name                = "id-agw-${var.project_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
}
