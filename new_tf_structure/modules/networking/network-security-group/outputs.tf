output "network_security_group_id" {
  description = "The ID of the Network Security Group"
  value       = azurerm_network_security_group.network-security-group.id
}

output "network_security_group_name" {
  description = "The name of the Network Security Group"
  value       = azurerm_network_security_group.network-security-group.name
}