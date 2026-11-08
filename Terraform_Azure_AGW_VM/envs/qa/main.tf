terraform {
  required_version = ">= 1.3"

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
  name                = "id-agw"
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  tags                = var.tags
}

module "keyvault" {
  source = "../../modules/keyvault"

  kv_name             = var.kv_name
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  tags                = var.tags

  secrets = {
    "vm-admin-password" = {
      value = var.admin_password
    }
  }

  certificates = {
    "agw-ssl-cert" = {
      subject = "CN=agw-p44010"
    }
  }

  access_policies = {
    agw = {
      object_id               = azurerm_user_assigned_identity.agw_identity.principal_id
      secret_permissions      = ["Get"]
      certificate_permissions = ["Get"]
    }
  }
}

module "networking" {
  source = "../../modules/networking"

  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  address_space       = var.address_space
  subnets             = var.subnets
  tags                = var.tags
}

module "vms" {
  source = "../../modules/vm"

  vms                 = var.vms
  subnet_id           = module.networking.subnet_ids["vm"]
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  admin_username      = var.admin_username
  admin_password      = module.keyvault.secret_values["vm-admin-password"]
  tags                = var.tags
}

module "disks" {
  source = "../../modules/disk"

  disks               = var.disks
  vm_ids              = module.vms.vm_ids
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  tags                = var.tags
}

module "agw" {
  source = "../../modules/agw"

  agw_name            = "main"
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  agw_subnet_id       = module.networking.subnet_ids["agw"]
  identity_id         = azurerm_user_assigned_identity.agw_identity.id
  tags                = var.tags

  backend_pools = {
    "agw-backend-pool" = {
      ip_addresses = values(module.vms.private_ips)
    }
  }

  ssl_certificates = {
    "agw-ssl-cert" = {
      key_vault_secret_id = module.keyvault.certificate_secret_ids["agw-ssl-cert"]
    }
  }
}

module "bastion" {
  source = "../../modules/bastion"

  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  bastion_subnet_id   = module.networking.subnet_ids["bastion"]
  tags                = var.tags
}
