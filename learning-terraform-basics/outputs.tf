# Virtual Machine Outputs
output "vm_id" {
  description = "The ID of the virtual machine"
  value       = module.virtual-machine.vm_id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = module.virtual-machine.vm_name
}

output "vm_private_ip_address" {
  description = "The private IP address of the virtual machine"
  value       = module.virtual-machine.vm_private_ip_address
}

output "vm_computer_name" {
  description = "The computer name of the virtual machine"
  value       = module.virtual-machine.vm_computer_name
}

# Network Outputs
output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = module.virtual-network.virtual_network_name
}