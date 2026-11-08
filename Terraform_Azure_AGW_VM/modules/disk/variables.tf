variable "disks" {
  description = <<-EOT
    Data disks προς δημιουργία και attach. Το key είναι σταθερό logical name
    (disk1, data, logs) και καθορίζει την ταυτότητα στο state — μετονομασία key
    σημαίνει destroy/create, δηλαδή χάσιμο δεδομένων.
    Το vm είναι το logical name του VM (key του vm_ids) όπου γίνεται το attach.
  EOT
  type = map(object({
    vm           = string
    disk_size_gb = number
    lun          = number
    disk_type    = optional(string, "Premium_LRS")
    caching      = optional(string, "ReadWrite")
    name         = optional(string) # αν λείπει, παράγεται από vm + key
  }))
  default = {}

  validation {
    condition = alltrue([
      for vm in distinct([for d in var.disks : d.vm]) :
      length(distinct([for d in var.disks : d.lun if d.vm == vm])) == length([for d in var.disks : d.lun if d.vm == vm])
    ])
    error_message = "Τα lun πρέπει να είναι μοναδικά ΑΝΑ VM (δύο VMs μπορούν κάλλιστα να έχουν lun 0)."
  }

  validation {
    condition     = alltrue([for d in var.disks : contains(["None", "ReadOnly", "ReadWrite"], d.caching)])
    error_message = "Το caching πρέπει να είναι None, ReadOnly ή ReadWrite."
  }
}

variable "vm_ids" {
  description = "Map logical name => VM id, από το output vm_ids του vm module."
  type        = map(string)
  default     = {}
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
