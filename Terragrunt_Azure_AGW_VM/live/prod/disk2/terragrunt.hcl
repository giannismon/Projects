include "root" { path = find_in_parent_folders() }

terraform { source = "../../../modules/disk" }

dependency "rg" { config_path = "../rg" }
dependency "vm" { config_path = "../vm" }

inputs = {
  vm_name             = "prod-2"
  resource_group_name = dependency.rg.outputs.rg_name
  location            = dependency.rg.outputs.rg_location
  vm_id               = dependency.vm.outputs.vm_id
  disk_size_gb        = 50
  disk_type           = "Premium_LRS"
  lun                 = 1
}
