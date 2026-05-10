variable "vm_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_id" {
  type = string
}

variable "disk_size_gb" {
  type    = number
  default = 100
}

variable "disk_type" {
  type    = string
  default = "Standard_LRS"
  # Options: Standard_LRS, StandardSSD_LRS, Premium_LRS
}

variable "lun" {
  type    = number
  default = 0
}
