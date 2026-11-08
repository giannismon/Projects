################################## Resource Group ##################################
rg_name  = "rg-prod"
location = "West Europe"

################################## Key Vault ##################################
kv_name = "kv-prod"

################################## Virtual Machine ##################################
vm_name        = "prod"
admin_username = "azureuser"
admin_password = "P@ssw0rd1234!"
vm_size        = "Standard_D2s_v3"
private_ip     = "10.0.1.10"

################################## Data Disks ##################################
disks = {
  disk1 = {
    disk_size_gb = 100
    disk_type    = "Premium_LRS"
    lun          = 0
  }

  disk2 = {
    disk_size_gb = 50
    disk_type    = "Premium_LRS"
    lun          = 1
  }

  # disk3 = {
  #   disk_size_gb = 256
  #   disk_type    = "Premium_LRS"
  #   lun          = 2
  #   caching      = "ReadOnly"
  # }
}

################################## Tags ##################################
tags = {
  environment = "prod"
  managed_by  = "terraform"
}
