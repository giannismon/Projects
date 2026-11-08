output "resource_group_name" {
  description = "Name of the resource group."
  value       = module.rg.rg_name
}

output "subnet_names" {
  description = "Map logical name => Azure subnet name."
  value       = module.networking.subnet_names
}

output "vm_names" {
  description = "Map logical name => Azure VM name."
  value       = module.vms.vm_names
}

output "vm_private_ips" {
  description = "Map logical name => private IP."
  value       = module.vms.private_ips
}

output "disk_names" {
  description = "Map logical name => managed disk name."
  value       = module.disks.disk_names
}

output "agw_public_ip" {
  description = "Public IP that serves web traffic."
  value       = module.agw.agw_public_ip
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion host."
  value       = module.bastion.bastion_public_ip
}
