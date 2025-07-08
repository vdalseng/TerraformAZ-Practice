
# Essential outputs for virtual machine module
# Only includes outputs that are commonly needed for integration or debugging

output "vm_id" {
    description = "The ID of the virtual machine"
    value       = azurerm_windows_virtual_machine.vm.id
}

output "vm_name" {
    description = "The name of the virtual machine"
    value       = azurerm_windows_virtual_machine.vm.name
}

output "vm_private_ip_address" {
    description = "The private IP address of the virtual machine"
    value       = azurerm_windows_virtual_machine.vm.private_ip_address
}

output "vm_computer_name" {
    description = "The computer name of the virtual machine"
    value       = azurerm_windows_virtual_machine.vm.computer_name
}
