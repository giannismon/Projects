resource "azurerm_managed_disk" "disk" {
  for_each = var.disks

  name                 = coalesce(each.value.name, "disk-monastiridis-${each.value.vm}-${each.key}")
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
  virtual_machine_id = var.vm_ids[var.disks[each.key].vm]
  lun                = var.disks[each.key].lun
  caching            = var.disks[each.key].caching

  lifecycle {
    precondition {
      condition     = contains(keys(var.vm_ids), var.disks[each.key].vm)
      error_message = "Disk ${each.key} points at a VM that is not in vm_ids."
    }
  }
}
