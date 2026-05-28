include "root" { path = find_in_parent_folders() }

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform { source = "../../../modules/identity" }

dependency "rg" { config_path = "../rg" }

inputs = {
  project_name        = local.env.project_name
  resource_group_name = dependency.rg.outputs.rg_name
  location            = dependency.rg.outputs.rg_location
}
