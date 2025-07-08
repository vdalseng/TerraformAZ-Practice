output "resource_group" {
  description = "The resource group created for the network"
  value = {
    name     = azurerm_resource_group.network.name
    location = azurerm_resource_group.network.location
    id       = azurerm_resource_group.network.id
  }
}

output "storage_account" {
  description = "The storage account created for demonstration"
  value = {
    name                  = azurerm_storage_account.example.name
    id                    = azurerm_storage_account.example.id
    primary_blob_endpoint = azurerm_storage_account.example.primary_blob_endpoint
  }
}

output "vnet_a" {
  description = "VNet A configuration and resources"
  value = module.vnet_a
}