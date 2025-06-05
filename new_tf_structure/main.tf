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

module "network-security-group" {
    source              = "./modules/networking/network-security-group"
    
    network_security_group_name     = var.network_security_group_name
    location                        = module.resource-group.location
    resource_group_name             = module.resource-group.resource_group_name
}

module "virtual-network" {
    source              = "./modules/networking/virtual-network"
    
    virtual_network_name        = var.virtual_network_name
    location                    = module.resource-group.location
    resource_group_name         = module.resource-group.resource_group_name
    address_space               = var.address_space
    network_security_group_id   = module.network-security-group.network_security_group_id
    tags                        = var.tags
}

module "subnet" {
    source              = "./modules/networking/subnet"
    
    subnet_name                 = var.subnet_name
    resource_group_name         = module.resource-group.resource_group_name
    virtual_network_name        = module.virtual-network.virtual_network_name
    address_prefix              = var.subnet_address_prefix
    service_endpoints           = var.service_endpoints
    network_security_group_id   = module.network-security-group.network_security_group_id
}

