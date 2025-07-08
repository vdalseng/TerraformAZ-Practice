output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.resource_group.name
}

output "location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.resource_group.location
}

output "id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.resource_group.id
}
