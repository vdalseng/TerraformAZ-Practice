
output "key_vault_id" {
    description = "The ID of the Key Vault"
    value       = { for k, v in azurerm_key_vault.key-vault-env : k => v.id }
}

output "key_vault_name" {
    description = "The name of the Key Vault"
    value       = { for k, v in azurerm_key_vault.key-vault-env : k => v.name }
}

output "key_vault_uri" {
    description = "The URI of the Key Vault"
    value       = { for k, v in azurerm_key_vault.key-vault-env : k => v.vault_uri }
}

output "key_vault_secret_id" {
    description = "The ID of the Key Vault Secret"
    value       = { for k, v in azurerm_key_vault_secret.key-vault-secret : k => v.id }
}

output "key_vault_secret_name" {
    description = "The name of the Key Vault Secret"
    value       = { for k, v in azurerm_key_vault_secret.key-vault-secret : k => v.name }
}
