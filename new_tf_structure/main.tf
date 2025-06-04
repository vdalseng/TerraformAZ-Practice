module "resource-group" {
    source              = "./modules/resource-group"
    
    resource_group_name = var.resource_group_name
    location            = var.location
    tags                = var.tags
}

module "storage-account" {
    source                      = "./modules/storage-account"
    
    resource_group_name         = module.resource-group.resource_group_name
    location                    = module.resource-group.location
    storage_account_name        = var.storage_account_name
    account_tier                = var.account_tier
    account_replication_type    = var.account_replication_type
    tags                        = var.tags
}

module "key-vault" {
    for_each                        = toset(var.environments)
    source                          = "./modules/key-vault"
    
    resource_group_name             = module.resource-group.resource_group_name
    location                        = module.resource-group.location
    key_vault_name                  = var.key_vault_name
    sku_name                        = var.sku_name
    tags                            = var.tags
    
    tenant_id                       = data.azurerm_client_config.current.tenant_id
    enabled_for_disk_encryption     = var.enabled_for_disk_encryption
    soft_delete_retention_days      = var.soft_delete_retention_days
    purge_protection_enabled        = var.purge_protection_enabled
    object_id                       = data.azurerm_client_config.current.object_id
    environments                    = [each.value]
    key_permissions                 = var.key_permissions
    secret_permissions              = var.secret_permissions
    storage_permissions             = var.storage_permissions

    key_vault_secret_name           = var.key_vault_secret_name
}