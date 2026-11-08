################################## Resource Group ##################################
rg_name  = "rg-qa"
location = "West Europe"

################################## Key Vault ##################################
kv_name = "kv-qa"

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
  qa = {
    private_ip   = "10.0.1.10"
    vm_size      = "Standard_B1s"
    os_disk_type = "Standard_LRS"
  }
  # app2 = {
  #   private_ip = "10.0.1.11"
  #   vm_size    = "Standard_B1s"
  # }
}

################################## Data Disks ##################################
disks = {
  disk1 = {
    vm           = "qa"
    disk_size_gb = 100
    disk_type    = "Standard_LRS"
    lun          = 0
  }
  disk2 = {
    vm           = "qa"
    disk_size_gb = 50
    disk_type    = "Standard_LRS"
    lun          = 1
  }
  # disk3 = {
  #   vm           = "app2"
  #   disk_size_gb = 256
  #   disk_type    = "Standard_LRS"
  #   lun          = 0
  #   caching      = "ReadOnly"
  # }
}

################################## Tags ##################################
tags = {
  environment = "qa"
  managed_by  = "terraform"
}
