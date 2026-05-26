include "root" { path = find_in_parent_folders() }

terraform { source = "../../../modules/networking" }

dependency "rg" { config_path = "../rg" }

inputs = {
  resource_group_name = dependency.rg.outputs.rg_name
  location            = dependency.rg.outputs.rg_location
}
