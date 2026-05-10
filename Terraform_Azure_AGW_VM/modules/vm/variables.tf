variable "vm_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "private_ip" {
  type    = string
  default = "10.0.1.10"
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "admin_username" {
  type    = string
  default = "example_user"
}

variable "admin_password" {
  type      = string
  sensitive = true
}
