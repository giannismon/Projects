variable "name_prefix" {
  description = "Naming prefix. Produces rg-<prefix> and aks-<prefix>."
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "tags" {
  description = "Tags applied to the resource group and cluster. Also used as node labels."
  type        = map(string)
  default     = {}
}

variable "kubernetes_version" {
  description = "null = whatever AKS defaults to. List options: az aks get-versions --location <region> -o table"
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "Free (no SLA, dev) or Standard (financially backed SLA, prod)"
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be one of: Free | Standard | Premium."
  }
}

variable "system_node_pool" {
  description = "The system pool. Runs CoreDNS and metrics-server — do not drop it below 2 nodes."
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
  description = "Application pools, keyed by pool name. An empty map means system pool only."
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

variable "network_plugin" {
  description = "azure (CNI) or kubenet"
  type        = string
  default     = "azure"
}

variable "local_account_disabled" {
  description = "true removes the cluster local admin and requires Entra RBAC. Dev: false."
  type        = bool
  default     = false
}
