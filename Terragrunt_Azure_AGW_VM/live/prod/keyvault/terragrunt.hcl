include "root" { path = find_in_parent_folders() }

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform { source = "../../../modules/keyvault" }

dependency "rg"       { config_path = "../rg" }
dependency "identity" { config_path = "../identity" }

inputs = {
  kv_name             = local.env.kv_name
  resource_group_name = dependency.rg.outputs.rg_name
  location            = dependency.rg.outputs.rg_location
  agw_principal_id    = dependency.identity.outputs.principal_id
}
