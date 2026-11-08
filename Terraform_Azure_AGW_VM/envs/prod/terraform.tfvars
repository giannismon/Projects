################################## Resource Group ##################################
rg_name  = "rg-prod"
location = "West Europe"

################################## Key Vault ##################################
kv_name = "kv-prod"

################################## Networking ##################################
address_space = ["10.0.0.0/16"]

subnets = {
  vm = {
    address_prefix = "10.0.1.0/24"
  }
  agw = {
    address_prefix = "10.0.2.0/24"
  }
  bastion = {
    address_prefix = "10.0.3.0/24"
    name           = "AzureBastionSubnet"
  }
}

################################## Virtual Machines ##################################
admin_username = "azureuser"
admin_password = "P@ssw0rd1234!"

vms = {
  prod = {
    private_ip   = "10.0.1.10"
    vm_size      = "Standard_D2s_v3"
    os_disk_type = "Standard_LRS"
  }
  # app2 = {
  #   private_ip = "10.0.1.11"
  #   vm_size    = "Standard_D2s_v3"
  # }
}

################################## Data Disks ##################################
disks = {
  disk1 = {
    vm           = "prod"
    disk_size_gb = 100
    disk_type    = "Premium_LRS"
    lun          = 0
  }
  disk2 = {
    vm           = "prod"
    disk_size_gb = 50
    disk_type    = "Premium_LRS"
    lun          = 1
  }
  # disk3 = {
  #   vm           = "app2"
  #   disk_size_gb = 256
  #   disk_type    = "Premium_LRS"
  #   lun          = 0
  #   caching      = "ReadOnly"
  # }
}

################################## Tags ##################################
tags = {
  environment = "prod"
  managed_by  = "terraform"
}
