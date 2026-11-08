variable "vms" {
  description = <<-EOT
    VMs προς δημιουργία. Το key είναι σταθερό logical name (prod, web1, app)
    και καθορίζει τα Azure names (vm-p44010-<key>, nic-p44010-<key>) και την
    ταυτότητα στο state — μετονομασία key σημαίνει destroy/create του VM.
    private_ip = null σημαίνει Dynamic allocation.
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
    error_message = "Δύο VMs δεν μπορούν να έχουν το ίδιο private_ip."
  }
}

variable "subnet_id" {
  description = "Subnet όπου μπαίνουν τα NICs όλων των VMs."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group των VMs."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "admin_username" {
  description = "Local admin username (κοινό σε όλα τα VMs)."
  type        = string
}

variable "admin_password" {
  description = "Local admin password (κοινό σε όλα τα VMs) — από το Key Vault."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags στα VMs και στα NICs."
  type        = map(string)
  default     = {}
}
