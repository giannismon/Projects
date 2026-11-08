resource "azurerm_network_interface" "nic" {
  for_each = var.vms

  name                = "nic-p44010-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = each.value.private_ip == null ? "Dynamic" : "Static"
    private_ip_address            = each.value.private_ip
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.vms

  name                            = "vm-p44010-${each.key}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = each.value.vm_size
  zone                            = each.value.zone
  admin_username                  = var.admin_username
  disable_password_authentication = false
  admin_password                  = var.admin_password
  tags                            = var.tags

  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = each.value.os_disk_type
  }

  source_image_reference {
    publisher = each.value.image.publisher
    offer     = each.value.image.offer
    sku       = each.value.image.sku
    version   = each.value.image.version
  }
}
