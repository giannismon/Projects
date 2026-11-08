resource "azurerm_managed_disk" "disk" {
  for_each = var.disks

  name                 = coalesce(each.value.name, "disk-p44010-${var.vm_name}-${each.key}")
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.disk_type
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "attachment" {
  for_each = azurerm_managed_disk.disk

  managed_disk_id    = each.value.id
  virtual_machine_id = var.vm_id
  lun                = var.disks[each.key].lun
  caching            = var.disks[each.key].caching
}
