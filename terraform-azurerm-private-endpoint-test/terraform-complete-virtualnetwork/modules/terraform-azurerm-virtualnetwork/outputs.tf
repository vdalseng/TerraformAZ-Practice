# Core Network Outputs
output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "azurerm_subnet" {
  description = "Map of subnet resources (required by main configuration)"
  value       = azurerm_subnet.subnet
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = { for name, subnet in azurerm_subnet.subnet : name => subnet.id }
}

# Private Endpoint Outputs
output "private_endpoint_ips" {
  description = "Map of private endpoint names to their private IP addresses"
  value       = { 
    for name, pe in azurerm_private_endpoint.private_endpoint : 
    name => pe.private_service_connection[0].private_ip_address 
  }
}

# DNS Zone Outputs
output "private_dns_zone_names" {
  description = "Map of DNS zone keys to their full names"
  value       = { for key, zone in azurerm_private_dns_zone.private_dns_zone : key => zone.name }
}

# Comprehensive Network Summary
output "network_summary" {
  description = "Comprehensive summary of the network configuration including all key components"
  value = {
    # Core Network Information
    vnet_name           = azurerm_virtual_network.vnet.name
    vnet_id             = azurerm_virtual_network.vnet.id
    resource_group      = azurerm_virtual_network.vnet.resource_group_name
    location            = azurerm_virtual_network.vnet.location
    address_space       = tolist(azurerm_virtual_network.vnet.address_space)
    
    # Subnet Information
    subnet_count        = length(azurerm_subnet.subnet)
    subnets = {
      for name, subnet in azurerm_subnet.subnet : name => {
        id            = subnet.id
        address_prefix = subnet.address_prefixes[0]
      }
    }
    
    # Private Endpoint Information
    private_endpoints = {
      count = length(azurerm_private_endpoint.private_endpoint)
      endpoints = {
        for name, pe in azurerm_private_endpoint.private_endpoint : name => {
          id         = pe.id
          private_ip = pe.private_service_connection[0].private_ip_address
          subnet     = pe.subnet_id
        }
      }
    }
    
    # DNS Configuration
    dns_zones = {
      count = length(azurerm_private_dns_zone.private_dns_zone)
      zones = { for key, zone in azurerm_private_dns_zone.private_dns_zone : key => zone.name }
    }
    
    # Peering Information
    peering = {
      enabled     = var.vnet_peering_config != null
      remote_vnet = var.vnet_peering_config != null ? var.vnet_peering_config.remote_vnet_name : null
      remote_rg   = var.vnet_peering_config != null ? var.vnet_peering_config.remote_rg_name : null
    }
    
    # Configuration Flags
    features = {
      ddos_protection_enabled = var.ddos_protection_plan_id != null
      custom_dns_servers      = length(var.dns_servers) > 0
    }
  }
}