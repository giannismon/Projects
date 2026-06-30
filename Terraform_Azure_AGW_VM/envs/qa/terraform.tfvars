################################## Resource Group ##################################
rg_name  = "rg-qa"
location = "West Europe"

################################## Key Vault ##################################
kv_name = "kv-qa"

################################## Virtual Machine ##################################
vm_name        = "qa"
admin_username = "azureuser"
admin_password = "P@ssw0rd1234!"
vm_size        = "Standard_B1s"
private_ip     = "10.0.1.10"

################################## Disk 1 ##################################
disk_size_gb = 100
disk_type    = "Standard_LRS"

################################## Disk 2 ##################################
disk2_size_gb = 50
disk2_type    = "Standard_LRS"

################################## Tags ##################################
tags = {
  environment = "qa"
  managed_by  = "terraform"
}
