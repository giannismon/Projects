variable "rg_name" {
  type = string
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "tags" {
  type    = map(string)
  default = {}
}
