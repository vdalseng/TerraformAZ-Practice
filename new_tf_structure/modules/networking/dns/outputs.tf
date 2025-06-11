output "private_dns_zone_id" {
    description = "The ID of the private DNS zone"
    value       = azurerm_private_dns_zone.dns_zone.id
}

output "private_dns_zone_name" {
    description = "The name of the private DNS zone"
    value       = azurerm_private_dns_zone.dns_zone.name
}