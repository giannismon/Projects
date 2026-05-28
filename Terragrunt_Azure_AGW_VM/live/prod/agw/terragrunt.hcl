include "root" { path = find_in_parent_folders() }

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform { source = "../../../modules/agw" }

dependency "rg"         { config_path = "../rg" }
dependency "networking" { config_path = "../networking" }
dependency "vm"         { config_path = "../vm" }
dependency "keyvault"   { config_path = "../keyvault" }
dependency "identity"   { config_path = "../identity" }

inputs = {
  agw_name                  = local.env.agw_name
  resource_group_name       = dependency.rg.outputs.rg_name
  location                  = dependency.rg.outputs.rg_location
  agw_subnet_id             = dependency.networking.outputs.agw_subnet_id
  vm_private_ip             = dependency.vm.outputs.private_ip
  ssl_certificate_secret_id = dependency.keyvault.outputs.ssl_certificate_secret_id
  identity_id               = dependency.identity.outputs.identity_id
  blocked_ip                = local.env.blocked_ip
}
