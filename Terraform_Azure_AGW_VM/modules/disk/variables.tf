variable "disks" {
  description = <<-EOT
    Data disks to create and attach. The key is a stable logical name
    (disk1, data, logs) and is the resource identity in state, so renaming a
    key means destroy and create, which for a disk means losing the data.
    vm is the logical name of the VM (a key of vm_ids) to attach to.
  EOT
  type = map(object({
    vm           = string
    disk_size_gb = number
    lun          = number
    disk_type    = optional(string, "Premium_LRS")
    caching      = optional(string, "ReadWrite")
    name         = optional(string) # defaults to vm + key
  }))
  default = {}

  validation {
    condition = alltrue([
      for vm in distinct([for d in var.disks : d.vm]) :
      length(distinct([for d in var.disks : d.lun if d.vm == vm])) == length([for d in var.disks : d.lun if d.vm == vm])
    ])
    error_message = "lun must be unique PER VM (two VMs may both use lun 0)."
  }

  validation {
    condition     = alltrue([for d in var.disks : contains(["None", "ReadOnly", "ReadWrite"], d.caching)])
    error_message = "caching must be None, ReadOnly or ReadWrite."
  }
}

variable "vm_ids" {
  description = "Map logical name => VM id, from the vm module's vm_ids output."
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Resource group of the disks."
  type        = string
}

variable "location" {
  description = "Azure region of the disks."
  type        = string
}

variable "tags" {
  description = "Tags applied to every disk."
  type        = map(string)
  default     = {}
}
