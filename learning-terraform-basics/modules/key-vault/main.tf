resource "random_password" "secret" {
  for_each = toset(var.environments)
  length   = 32
  special  = true
}

resource "azurerm_key_vault" "key-vault-env" {
    for_each = toset(var.environments)

    name                        = "${var.key_vault_name}-${each.value}"
    location                    = var.location
    resource_group_name         = var.resource_group_name
    // SKUs define the pricing tier for the Key Vault
    sku_name                    = var.sku_name
    tenant_id                   = var.tenant_id
    enabled_for_disk_encryption = var.enabled_for_disk_encryption
    soft_delete_retention_days  = var.soft_delete_retention_days
    purge_protection_enabled    = var.purge_protection_enabled

    tags                        = var.tags

    access_policy {
        // This access policy allows the current authenticated user to manage secrets and keys
        tenant_id   = var.tenant_id
        object_id   = var.object_id

        key_permissions         = var.key_permissions
        secret_permissions      = var.secret_permissions
        storage_permissions     = var.storage_permissions
    }
}

resource "azurerm_key_vault_secret" "key-vault-secret" {
    for_each        = toset(var.environments)

    name            = "${var.key_vault_secret_name}-${each.value}"
    value           = random_password.secret[each.key].result
    key_vault_id    = azurerm_key_vault.key-vault-env[each.key].id
}
