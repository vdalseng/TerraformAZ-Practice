provider "azurerm" {
    subscription_id = var.subscription_id
#   client_id       = var.client_id
#   client_secret   = var.client_secret
#   tenant_id       = var.tenant_id
    features {}
}
// Fetch the currently authenticated Azure client
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "vetle-rg" {
    // In most resources, the name and location are required
    name     = "vetle-private-networking-rg"
    location = "North Europe"

    tags = {
      environment = "shared"
    }
}

// This is a local variable that defines the environments
locals {
    environments = ["dev", "test", "prod"]
}

// AzureRM Storage Account for general purpose use
// Can store blobs, files, tables, and queues
// GRS enables geo-redundant storage for disaster recovery
resource "azurerm_storage_account" "vetle-sa" {
    name                     = "vetlesa"
    resource_group_name      = azurerm_resource_group.vetle-rg.name
    location                 = azurerm_resource_group.vetle-rg.location
    account_tier             = "Standard"
    account_replication_type = "GRS"

    // Tags are optional, but recommended for organization
    tags = {
    // This tag clarifies that the resource is shared and can be used by multiple environments
        environment = "shared"
    }
}

// AzureRM Key Vault for storing secrets and keys
// Integrated with Azure Storage Account for secure access
resource "azurerm_key_vault" "vetlekv-env" {
    for_each = toset(local.environments)
    name                        = "vetlekv-${each.value}"
    location                    = azurerm_resource_group.vetle-rg.location
    resource_group_name         = azurerm_resource_group.vetle-rg.name
    enabled_for_disk_encryption = true
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    soft_delete_retention_days  = 7
    purge_protection_enabled    = false

    // SKUs define the pricing tier for the Key Vault
    sku_name                    = "standard"

    access_policy {
        // This access policy allows the current authenticated user to manage secrets and keys
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = data.azurerm_client_config.current.object_id

        key_permissions = [
        "Get",
        ]

        secret_permissions = [
        "Get", "Set", "List",
        ]

        storage_permissions = [
        "Get",
        ]
    }
}


resource "azurerm_key_vault_secret" "vetle-kv-secret" {
    for_each = toset(local.environments)
    name         = "storage-account-key-${each.value}"
    value        = azurerm_storage_account.vetle-sa.primary_access_key
    key_vault_id = azurerm_key_vault.vetlekv-env[each.key].id
}




