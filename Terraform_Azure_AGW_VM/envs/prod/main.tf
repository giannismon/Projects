terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

module "rg" {
  source = "../../modules/rg"

  rg_name  = var.rg_name
  location = var.location
  tags     = var.tags
}

module "keyvault" {
  source = "../../modules/keyvault"

  kv_name             = var.kv_name
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  admin_password      = var.admin_password
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-p44010-main"
  address_space       = ["10.0.0.0/16"]
  location            = module.rg.rg_location
  resource_group_name = module.rg.rg_name
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "subnet-vm-p44010"
  resource_group_name  = module.rg.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "agw_subnet" {
  name                 = "subnet-agw-p44010"
  resource_group_name  = module.rg.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = module.rg.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

module "vm" {
  source = "../../modules/vm"

  vm_name             = var.vm_name
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  subnet_id           = azurerm_subnet.vm_subnet.id
  private_ip          = var.private_ip
  admin_username      = var.admin_username
  admin_password      = module.keyvault.vm_password
  vm_size             = var.vm_size
}

module "disk" {
  source = "../../modules/disk"

  vm_name             = var.vm_name
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  vm_id               = module.vm.vm_id
  disk_size_gb        = var.disk_size_gb
  disk_type           = var.disk_type
  lun                 = 0
}

module "disk2" {
  source = "../../modules/disk"

  vm_name             = "${var.vm_name}-2"
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  vm_id               = module.vm.vm_id
  disk_size_gb        = var.disk2_size_gb
  disk_type           = var.disk2_type
  lun                 = 1
}

module "agw" {
  source = "../../modules/agw"

  agw_name            = "main"
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  agw_subnet_id       = azurerm_subnet.agw_subnet.id
  vm_private_ip       = module.vm.private_ip
}

module "bastion" {
  source = "../../modules/bastion"

  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  bastion_subnet_id   = azurerm_subnet.bastion_subnet.id
}
