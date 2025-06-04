output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.vetle-rg.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.vetle-sa.name
}

output "key_vault_names" {
  description = "Key Vault names by environment"
  value       = { for k, v in azurerm_key_vault.vetlekv-env : k => v.name }
}

# Sensitive outputs (use with caution)
output "storage_account_key" {
  description = "Storage account primary access key"
  value       = azurerm_storage_account.vetle-sa.primary_access_key
  sensitive   = true
}