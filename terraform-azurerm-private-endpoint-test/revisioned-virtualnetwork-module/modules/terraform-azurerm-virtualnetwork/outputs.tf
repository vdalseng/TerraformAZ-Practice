output "vnet" {
    description = "Virtual Network"
    value       = azurerm_virtual_network.vnet
}

output "subnet" {
    description = "Subnets"
    value       = azurerm_subnet.subnet
}

output "private_endpoint_ips" {
    description = "Map of private endpoint names to their private IP addresses"
    value = {
        for name, pe in azurerm_private_endpoint.private_endpoint :
        name => pe.private_service_connection[0].private_ip_address
    }
}

output "private_dns_zones" {
  description = "Private DNS zones created for private endpoints"
  value       = azurerm_private_dns_zone.private_dns_zone
}

output "dns_zone_ids" {
  description = "Map of DNS zone names (with dots replaced by underscores) to their IDs"
  value = local.dns_zone_ids
}