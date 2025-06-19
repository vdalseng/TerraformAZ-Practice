output "azurerm_vnet" {
  description = "The virtual network resource"
  value       = azurerm_virtual_network.vnet
}

output "azurerm_subnet" {
  description = "Map of subnet resources"
  value       = azurerm_subnet.subnet
}

output "azurerm_private_endpoint" {
  description = "Map of private endpoint resources"
  value       = azurerm_private_endpoint.private_endpoint
}

output "azurerm_vnet_peering" {
  description = "The VNet peering resource (if created)"
  value       = length(azurerm_virtual_network_peering.local_to_remote) > 0 ? azurerm_virtual_network_peering.local_to_remote[0] : null
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "The address space of the virtual network"
  value       = azurerm_virtual_network.vnet.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = { for name, subnet in azurerm_subnet.subnet : name => subnet.id }
}

output "subnet_cidrs" {
  description = "Map of subnet names to their CIDR blocks"
  value       = { for name, subnet in azurerm_subnet.subnet : name => subnet.address_prefixes[0] }
}

output "private_endpoint_ips" {
  description = "Map of private endpoint names to their private IP addresses"
  value       = { 
    for name, pe in azurerm_private_endpoint.private_endpoint : 
    name => pe.private_service_connection[0].private_ip_address 
  }
}

output "network_summary" {
  description = "Summary of network configuration for easy reference"
  value = {
    vnet_name         = azurerm_virtual_network.vnet.name
    vnet_id           = azurerm_virtual_network.vnet.id
    address_space     = azurerm_virtual_network.vnet.address_space[0]
    subnet_count      = length(azurerm_subnet.subnet)
    pe_count          = length(azurerm_private_endpoint.private_endpoint)
    peering_enabled   = var.vnet_peering_config != null
    resource_group    = azurerm_virtual_network.vnet.resource_group_name
    location          = azurerm_virtual_network.vnet.location
  }
}