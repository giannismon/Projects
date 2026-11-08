variable "rg_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for every resource."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
}

variable "kv_name" {
  description = "Name of the Key Vault, globally unique."
  type        = string
}

variable "admin_username" {
  description = "Local admin username of the VMs."
  type        = string
}

variable "admin_password" {
  description = "Local admin password, stored in Key Vault as vm-admin-password."
  type        = string
  sensitive   = true
}

variable "address_space" {
  description = "Address space of the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Subnets keyed by logical name. The Bastion one needs name = AzureBastionSubnet."
  type = map(object({
    address_prefix    = string
    name              = optional(string)
    service_endpoints = optional(list(string))
  }))
}

variable "vms" {
  description = "VMs keyed by logical name. The key becomes vm-monastiridis-<key>."
  type = map(object({
    private_ip   = optional(string)
    vm_size      = optional(string, "Standard_B1s")
    os_disk_type = optional(string, "Standard_LRS")
    zone         = optional(string)
    image = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = optional(string, "latest")
    }))
  }))
}

variable "disks" {
  description = "Data disks keyed by logical name. vm references a key of vms."
  type = map(object({
    vm           = string
    disk_size_gb = number
    lun          = number
    disk_type    = optional(string, "Premium_LRS")
    caching      = optional(string, "ReadWrite")
    name         = optional(string)
  }))
  default = {}
}
