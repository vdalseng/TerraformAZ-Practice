output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = azurerm_private_endpoint.private_endpoint.id
}

output "private_endpoint_name" {
  description = "Name of the private endpoint"
  value       = azurerm_private_endpoint.private_endpoint.name
}

output "private_ip_address" {
  description = "Private IP address of the private endpoint"
  value       = azurerm_private_endpoint.private_endpoint.private_service_connection[0].private_ip_address
}

output "network_interface_id" {
  description = "Network interface ID of the private endpoint"
  value       = azurerm_private_endpoint.private_endpoint.network_interface[0].id
}
