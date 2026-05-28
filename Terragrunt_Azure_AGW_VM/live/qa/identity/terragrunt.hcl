include "root" { path = find_in_parent_folders() }

terraform { source = "../../../modules/identity" }

dependency "rg" { config_path = "../rg" }

inputs = {
  project_name        = "ioannis"
  resource_group_name = dependency.rg.outputs.rg_name
  location            = dependency.rg.outputs.rg_location
}
