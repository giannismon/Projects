locals {
  location       = "West Europe"
  tags = {
    environment = "qa"
    managed_by  = "terraform"
  }
  project_name   = "ioannis"
  rg_name        = "rg-ioannis-qa"
  kv_name        = "kv-ioannis-qa"
  vm_name        = "qa"
  vm_size        = "Standard_B1s"
  admin_username = "azureuser"
  private_ip     = "10.0.1.10"
  disk_size_gb   = 100
  disk_type      = "Standard_LRS"
  disk2_size_gb  = 50
  disk2_type     = "Standard_LRS"
  agw_name       = "main"
  blocked_ip     = "1.2.3.4/32"
  admin_password = "MyP@ssword123!"
}
