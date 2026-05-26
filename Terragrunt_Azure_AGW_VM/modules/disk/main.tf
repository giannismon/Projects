resource "azurerm_managed_disk" "disk" {
  name                 = "disk-p44010-${var.vm_name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.disk_type
  create_option        = "Empty"
  disk_size_gb         = var.disk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "attachment" {
  managed_disk_id    = azurerm_managed_disk.disk.id
  virtual_machine_id = var.vm_id
  lun                = var.lun
  caching            = "ReadWrite"
}
