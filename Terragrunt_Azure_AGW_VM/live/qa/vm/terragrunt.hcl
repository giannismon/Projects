include "root" { path = find_in_parent_folders() }

terraform { source = "../../../modules/vm" }

dependency "rg"         { config_path = "../rg" }
dependency "networking" { config_path = "../networking" }
dependency "keyvault"   { config_path = "../keyvault" }

inputs = {
  vm_name             = "qa"
  resource_group_name = dependency.rg.outputs.rg_name
  location            = dependency.rg.outputs.rg_location
  subnet_id           = dependency.networking.outputs.vm_subnet_id
  private_ip          = "10.0.1.10"
  admin_username      = "azureuser"
  admin_password      = dependency.keyvault.outputs.vm_password
  vm_size             = "Standard_B1s"
}
