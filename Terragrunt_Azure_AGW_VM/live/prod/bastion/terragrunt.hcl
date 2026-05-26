include "root" { path = find_in_parent_folders() }

terraform { source = "../../../modules/bastion" }

dependency "rg"         { config_path = "../rg" }
dependency "networking" { config_path = "../networking" }

inputs = {
  resource_group_name = dependency.rg.outputs.rg_name
  location            = dependency.rg.outputs.rg_location
  bastion_subnet_id   = dependency.networking.outputs.bastion_subnet_id
}
