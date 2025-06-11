resource "azurerm_private_dns_zone" "dns_zone" {
    name                    = "privatelink.${var.service_type}.${var.azure_environment}"
    resource_group_name     = var.resource_group_name
    tags                    = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
    name                  = "dns-vnet-link-${var.service_type}"
    resource_group_name   = var.resource_group_name
    private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
    virtual_network_id    = var.virtual_network_id
    registration_enabled  = false
    tags                  = var.tags
}