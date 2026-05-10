output "resource_group_name" {
  value = module.rg.rg_name
}

output "vm_private_ip" {
  value = module.vm.private_ip
}

output "disk_name" {
  value = module.disk.disk_name
}

output "disk2_name" {
  value = module.disk2.disk_name
}

output "agw_public_ip" {
  description = "Public IP για web traffic"
  value       = module.agw.agw_public_ip
}

output "bastion_public_ip" {
  description = "Public IP του Bastion"
  value       = module.bastion.bastion_public_ip
}
