# One Bastion host per VNet: Azure does not allow a second one in the same
# AzureBastionSubnet, so there is no for_each to apply here.
resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bastion-monastiridis"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bastion-monastiridis"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}
