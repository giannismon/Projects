include "root" { path = find_in_parent_folders() }

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform { source = "../../../modules/rg" }

inputs = {
  rg_name  = "rg-ioannis-qa"
  location = local.env.location
  tags     = local.env.tags
}
