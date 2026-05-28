locals {
  location       = "West Europe"
  tags = {
    environment = "prod"
    managed_by  = "terraform"
  }
  project_name   = "ioannis"
  rg_name        = "rg-ioannis-prod"
  kv_name        = "kv-ioannis-prod"
  vm_name        = "prod"
  vm_size        = "Standard_D2s_v3"
  admin_username = "azureuser"
  private_ip     = "10.0.1.10"
  disk_size_gb   = 100
  disk_type      = "Premium_LRS"
  disk2_size_gb  = 50
  disk2_type     = "Premium_LRS"
  agw_name       = "main"
  blocked_ip     = "1.2.3.4/32"
  admin_password = "MyP@ssword123!"
}
