resource "azurerm_storage_account" "storage_account" {
    name                     = var.storage_account_name
    resource_group_name      = var.resource_group_name
    location                 = var.location
    account_tier             = var.account_tier
    account_replication_type = var.account_replication_type

    public_network_access_enabled = false
    
    network_rules {
        default_action             = "Deny"
        bypass                     = ["AzureServices"]
        ip_rules                   = ["188.95.241.183"]
    }
    
    tags = var.tags
}

resource "azurerm_storage_container" "tfstate" {
    name                  = "tfstate"
    storage_account_id    = azurerm_storage_account.storage_account.id
    container_access_type = "private"
}