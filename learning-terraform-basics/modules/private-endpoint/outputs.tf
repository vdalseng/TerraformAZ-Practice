output "private_endpoint_id" {
    description = "The ID of the private endpoint"
    value       = azurerm_private_endpoint.private_endpoint.id
}

output "private_endpoint_name" {
    description = "The name of the private endpoint"
    value       = azurerm_private_endpoint.private_endpoint.name
}

output "private_endpoint_network_interface" {
    description = "The network interface of the private endpoint"
    value       = azurerm_private_endpoint.private_endpoint.network_interface
}