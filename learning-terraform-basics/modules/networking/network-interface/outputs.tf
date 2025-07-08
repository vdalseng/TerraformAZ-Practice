
output "network_interface_id" {
    description = "The ID of the network interface"
    value       = azurerm_network_interface.nic.id
}

output "network_interface_name" {
    description = "The name of the network interface"
    value       = azurerm_network_interface.nic.name
}
