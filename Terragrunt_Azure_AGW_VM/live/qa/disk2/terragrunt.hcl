include "root" { path = find_in_parent_folders() }

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform { source = "../../../modules/disk" }

dependency "rg" { config_path = "../rg" }
dependency "vm" { config_path = "../vm" }

inputs = {
  vm_name             = "${local.env.vm_name}-2"
  resource_group_name = dependency.rg.outputs.rg_name
  location            = dependency.rg.outputs.rg_location
  vm_id               = dependency.vm.outputs.vm_id
  disk_size_gb        = local.env.disk2_size_gb
  disk_type           = local.env.disk2_type
  lun                 = 1
}
