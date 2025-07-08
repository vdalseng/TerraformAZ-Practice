# Subnet Resource ID - Essential for referencing the subnet in other resources
output "subnet_id" {
    description = "The ID of the subnet"
    value       = azurerm_subnet.subnet.id
}

# Subnet Name - Useful for referencing and identification
output "subnet_name" {
    description = "The name of the subnet"
    value       = azurerm_subnet.subnet.name
}

# Subnet Address Prefixes - Important for networking configuration and troubleshooting
output "address_prefixes" {
    description = "The address prefixes assigned to the subnet"
    value       = azurerm_subnet.subnet.address_prefixes
}

# Service Endpoints - Important for service integration
output "service_endpoints" {
    description = "The service endpoints configured for the subnet"
    value       = azurerm_subnet.subnet.service_endpoints
}

output "bastion_subnet_id" {
    description = "The ID of the bastion subnet"
    value       = azurerm_subnet.bastion_subnet.id
}