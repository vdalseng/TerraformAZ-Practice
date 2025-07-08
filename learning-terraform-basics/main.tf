module "resource-group" {
    source              = "./modules/resource-group"
    
    resource_group_name = var.resource_group_name
    location            = var.location
    tags                = var.tags
}

# module "network-security-group" {
#     source              = "./modules/networking/network-security-group"
    
#     network_security_group_name     = var.network_security_group_name
#     location                        = module.resource-group.location
#     resource_group_name             = module.resource-group.resource_group_name
# }

module "virtual-network" {
    source              = "./modules/networking/virtual-network"
    
    virtual_network_name        = var.virtual_network_name
    location                    = module.resource-group.location
    resource_group_name         = module.resource-group.resource_group_name
    address_space               = var.address_space
    tags                        = var.tags

    bastion_subnet_id           = module.subnet.bastion_subnet_id
}

module "subnet" {
    source              = "./modules/networking/subnet"
    
    subnet_name                     = var.subnet_name
    resource_group_name             = module.resource-group.resource_group_name
    virtual_network_name            = module.virtual-network.virtual_network_name
    address_prefix                  = var.subnet_address_prefix
    bastion_subnet_address_prefix   = var.bastion_subnet_address_prefix
}

module "storage-account" {
    source                      = "./modules/storage-account"
    
    resource_group_name         = module.resource-group.resource_group_name
    location                    = module.resource-group.location
    storage_account_name        = var.storage_account_name
    account_tier                = var.account_tier
    account_replication_type    = var.account_replication_type
    tags                        = var.tags
    subnet_id                   = module.subnet.subnet_id
}

# module "key-vault" {
#     for_each                        = toset(var.environments)
#     source                          = "./modules/key-vault"
    
#     resource_group_name             = module.resource-group.resource_group_name
#     location                        = module.resource-group.location
#     key_vault_name                  = var.key_vault_name
#     sku_name                        = var.sku_name
#     tags                            = var.tags
    
#     tenant_id                       = data.azurerm_client_config.current.tenant_id
#     enabled_for_disk_encryption     = var.enabled_for_disk_encryption
#     soft_delete_retention_days      = var.soft_delete_retention_days
#     purge_protection_enabled        = var.purge_protection_enabled
#     object_id                       = data.azurerm_client_config.current.object_id
#     environments                    = [each.value]
#     key_permissions                 = var.key_permissions
#     secret_permissions              = var.secret_permissions
#     storage_permissions             = var.storage_permissions

#     key_vault_secret_name           = var.key_vault_secret_name
# }

# module "dns" {
#     source                  = "./modules/networking/dns"
    
#     resource_group_name     = module.resource-group.resource_group_name
#     virtual_network_id      = module.virtual-network.virtual_network_id
#     service_type            = var.service_type
#     azure_environment       = var.azure_environment
#     tags                    = var.tags
# }

module "private-endpoint" {
    source                          = "./modules/private-endpoint"
    
    private_endpoint_name           = var.private_endpoint_name
    location                        = module.resource-group.location
    resource_group_name             = module.resource-group.resource_group_name
    subnet_id                       = module.subnet.subnet_id
    private_service_connection_name = var.private_service_connection_name
    private_connection_resource_id  = module.storage-account.storage_account_id
    subresource_names              = var.subresource_names
    # dns_zone_group_name            = var.dns_zone_group_name
    # private_dns_zone_ids           = [module.dns.private_dns_zone_id]
    tags                           = var.tags
}

module "network-interface" {
    source                      = "./modules/networking/network-interface"
    
    network_interface_name      = var.network_interface_name
    location                    = module.resource-group.location
    resource_group_name         = module.resource-group.resource_group_name
    subnet_id                   = module.subnet.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address          = var.private_ip_address
    public_ip_address_id        = var.public_ip_address_id
    tags                        = var.tags
}

module "virtual-machine" {
    source                  = "./modules/virtual-machine"
    
    vm_name                 = var.vm_name
    location                = module.resource-group.location
    resource_group_name     = module.resource-group.resource_group_name
    network_interface_id    = module.network-interface.network_interface_id
    vm_size                 = var.vm_size
    image_publisher         = var.image_publisher
    image_offer             = var.image_offer
    image_sku               = var.image_sku
    image_version           = var.image_version
    admin_username          = var.admin_username
    admin_password          = var.admin_password
    
    # Azure Spot VM configuration for cost savings
    priority                = var.priority
    eviction_policy         = var.eviction_policy
    max_bid_price           = var.max_bid_price
    
    tags                    = var.tags
}