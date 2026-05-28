include "root" { path = find_in_parent_folders() }

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform { source = "../../../modules/vm" }

dependency "rg"         { config_path = "../rg" }
dependency "networking" { config_path = "../networking" }
dependency "keyvault"   { config_path = "../keyvault" }

inputs = {
  vm_name             = local.env.vm_name
  resource_group_name = dependency.rg.outputs.rg_name
  location            = dependency.rg.outputs.rg_location
  subnet_id           = dependency.networking.outputs.vm_subnet_id
  private_ip          = local.env.private_ip
  admin_username      = local.env.admin_username
  admin_password      = local.env.admin_password
  vm_size             = local.env.vm_size
}
