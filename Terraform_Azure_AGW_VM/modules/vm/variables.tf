variable "vms" {
  description = <<-EOT
    VMs to create. The key is a stable logical name (prod, web1, app) that
    drives the Azure names (vm-monastiridis-<key>, nic-monastiridis-<key>) and
    is the resource identity in state, so renaming a key destroys and recreates
    the VM. private_ip = null means Dynamic allocation.
  EOT
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
      }), {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts"
      version   = "latest"
    })
  }))

  validation {
    condition     = length(distinct([for v in var.vms : v.private_ip if v.private_ip != null])) == length([for v in var.vms : v.private_ip if v.private_ip != null])
    error_message = "Two VMs cannot share the same private_ip."
  }
}

variable "subnet_id" {
  description = "Subnet that holds the NICs of every VM."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group of the VMs."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "admin_username" {
  description = "Local admin username, shared by every VM."
  type        = string
}

variable "admin_password" {
  description = "Local admin password, shared by every VM, read from Key Vault."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to the VMs and their NICs."
  type        = map(string)
  default     = {}
}
