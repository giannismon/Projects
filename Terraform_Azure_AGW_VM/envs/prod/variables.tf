variable "rg_name" {
  description = "Όνομα του resource group."
  type        = string
}

variable "location" {
  description = "Azure region για όλα τα resources."
  type        = string
}

variable "tags" {
  description = "Tags σε όλα τα resources."
  type        = map(string)
}

variable "kv_name" {
  description = "Όνομα του Key Vault (globally unique)."
  type        = string
}

variable "admin_username" {
  description = "Local admin username των VMs."
  type        = string
}

variable "admin_password" {
  description = "Local admin password — αποθηκεύεται στο Key Vault ως vm-admin-password."
  type        = string
  sensitive   = true
}

variable "address_space" {
  description = "Address space του vnet."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Subnets, keyed by logical name. Το bastion θέλει name = AzureBastionSubnet."
  type = map(object({
    address_prefix    = string
    name              = optional(string)
    service_endpoints = optional(list(string))
  }))
}

variable "vms" {
  description = "VMs, keyed by logical name. Το key γίνεται vm-p44010-<key>."
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
  description = "Data disks, keyed by logical name. Το vm δείχνει σε key του vms."
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
