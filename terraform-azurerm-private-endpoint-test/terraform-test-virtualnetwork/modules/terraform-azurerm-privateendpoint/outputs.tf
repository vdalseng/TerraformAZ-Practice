output "private_endpoint_id" {
    description = "The ID of the private endpoint"
    value       = azurerm_private_endpoint.private_endpoint.id
}

output "private_service_connections" {
    description = "Map of private service connection details including private IP addresses"
    value = {
        for connection in azurerm_private_endpoint.private_endpoint.private_service_connection :
        connection.name => {
            name                           = connection.name
            private_connection_resource_id = connection.private_connection_resource_id
            subresource_names              = connection.subresource_names
            private_ip_address             = connection.private_ip_address
        }
    }
}