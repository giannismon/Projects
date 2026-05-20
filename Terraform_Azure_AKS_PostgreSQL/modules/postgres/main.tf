resource "azurerm_postgresql_flexible_server" "main" {
  name                          = "psql-${var.prefix}-${var.suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  version                       = "16"
  administrator_login           = "pgadmin"
  administrator_password        = var.password
  sku_name                      = "B_Standard_B1ms"
  storage_mb                    = 32768
  zone                          = "1"
  delegated_subnet_id           = var.subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = false
}
