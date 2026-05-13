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

resource "azurerm_user_assigned_identity" "agw_identity" {
  name                = "id-agw-p44010"
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
}

module "keyvault" {
  source = "../../modules/keyvault"

  kv_name             = var.kv_name
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  admin_password      = var.admin_password
  agw_principal_id    = azurerm_user_assigned_identity.agw_identity.principal_id
}

module "networking" {
  source = "../../modules/networking"

  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
}

module "vm" {
  source = "../../modules/vm"

  vm_name             = var.vm_name
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  subnet_id           = module.networking.vm_subnet_id
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

  agw_name                  = "main"
  resource_group_name       = module.rg.rg_name
  location                  = module.rg.rg_location
  agw_subnet_id             = module.networking.agw_subnet_id
  vm_private_ip             = module.vm.private_ip
  ssl_certificate_secret_id = module.keyvault.ssl_certificate_secret_id
  identity_id               = azurerm_user_assigned_identity.agw_identity.id
}

module "bastion" {
  source = "../../modules/bastion"

  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  bastion_subnet_id   = module.networking.bastion_subnet_id
}
