variable "disks" {
  description = <<-EOT
    Data disks προς δημιουργία και attach στο VM.
    Το key είναι σταθερό logical name (disk1, data, logs) και καθορίζει την ταυτότητα
    του resource στο state — μετονομασία key σημαίνει destroy/create.
  EOT
  type = map(object({
    disk_size_gb = number
    lun          = number
    disk_type    = optional(string, "Premium_LRS")
    caching      = optional(string, "ReadWrite")
    name         = optional(string) # αν λείπει, παράγεται από vm_name + key
  }))
  default = {}

  validation {
    condition     = length(distinct([for d in var.disks : d.lun])) == length(var.disks)
    error_message = "Κάθε disk πρέπει να έχει μοναδικό lun."
  }

  validation {
    condition     = alltrue([for d in var.disks : contains(["None", "ReadOnly", "ReadWrite"], d.caching)])
    error_message = "Το caching πρέπει να είναι None, ReadOnly ή ReadWrite."
  }
}

variable "vm_name" {
  description = "Όνομα του VM — μπαίνει στο default naming των δίσκων."
  type        = string
}

variable "vm_id" {
  description = "Resource id του VM όπου γίνεται το attachment."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group των δίσκων."
  type        = string
}

variable "location" {
  description = "Azure region των δίσκων."
  type        = string
}

variable "tags" {
  description = "Tags σε όλους τους δίσκους."
  type        = map(string)
  default     = {}
}
