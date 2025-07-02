output "vnet" {
    description = "Virtual Network"
    value       = azurerm_virtual_network.vnet.id
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

output "private_dns_zone_names" {
  description = "Map of DNS zone keys to their full names"
  value       = { for key, zone in azurerm_private_dns_zone.private_dns_zone : key => zone.name }
}