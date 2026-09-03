variable "subscription_id" {
  description = "Target subscription GUID. Declared explicitly because az login may default to a different subscription."
  type        = string
}

variable "name_prefix" {
  type = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "tags" {
  type = map(string)
}

variable "system_node_pool" {
  type = object({
    name            = optional(string, "system")
    vm_size         = optional(string, "Standard_D2s_v3")
    os_disk_size_gb = optional(number, 50)
    node_count      = optional(number, 2)
    min_count       = optional(number, 1)
    max_count       = optional(number, 3)
  })
  default = {}
}

variable "user_node_pools" {
  type = map(object({
    vm_size         = optional(string, "Standard_D2s_v3")
    os_disk_size_gb = optional(number, 50)
    node_count      = optional(number, 1)
    min_count       = optional(number, 1)
    max_count       = optional(number, 3)
    node_labels     = optional(map(string), {})
    node_taints     = optional(list(string), [])
  }))
  default = {}
}
