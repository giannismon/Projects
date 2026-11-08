# Ένα Bastion host ανά vnet — το Azure δεν επιτρέπει δεύτερο στο ίδιο
# AzureBastionSubnet, οπότε εδώ δεν υπάρχει for_each να γίνει.
resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bastion-p44010"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bastion-p44010"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}
