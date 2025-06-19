locals {
  standard_name = "${var.system_name}-${var.environment}"
  # vnet          = concat(azurerm_virtual_network.vnet.*, [null])[0]
  # subnet        = concat(azurerm_subnet.subnet.*, [null])
  # subnet_count  = length(azurerm_subnet.subnet)
  
  # Peering-related locals - only calculated if peering config is provided
  vnet_name = var.name_override != "" ? var.name_override : local.standard_name
  # Extract remote resource group from remote VNet ID
  remote_rg_name = var.vnet_peering_config != null ? split("/", var.vnet_peering_config.remote_virtual_network_id)[4] : ""
    # Generate peering name: local-vnet-to-remote-vnet
  peering_name = var.vnet_peering_config != null ? "${local.vnet_name}-to-${var.vnet_peering_config.virtual_network_name}" : ""
}

# Data source to verify remote VNet exists before creating peering
data "azurerm_virtual_network" "remote_vnet" {
  count               = var.vnet_peering_config != null ? 1 : 0
  name                = var.vnet_peering_config != null ? var.vnet_peering_config.virtual_network_name : ""
  resource_group_name = local.remote_rg_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id != null ? [1] : []
    content {
      id = var.ddos_protection_plan_id
      enable = true
    }
  }
  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each                          = var.subnet_configs
  name                              = each.key
  resource_group_name               = var.resource_group.name
  address_prefixes                  = [each.value]
  virtual_network_name              = azurerm_virtual_network.vnet.name
  private_endpoint_network_policies = var.private_endpoint_network_policies
}

resource "azurerm_private_endpoint" "private_endpoint" {
  for_each            = var.private_endpoint_configs
    # Auto-generate PE name: system-environment-identifier-pe
  name                = "${local.vnet_name}-${each.key}-pe"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  subnet_id           = each.value.subnet_id
  
  private_service_connection {    # Auto-generate connection name: system-environment-identifier-connection
    name                           = "${local.vnet_name}-${each.key}-connection"
    private_connection_resource_id = each.value.resource_id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = false
  }

  # Optional private DNS zone group configuration
  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_group != null ? [each.value.private_dns_zone_group] : []
    content {
      name                 = private_dns_zone_group.value.name
      private_dns_zone_ids = private_dns_zone_group.value.private_dns_zone_ids
    }
  }

  tags = var.tags
}

# VNet Peering - single-way peering FROM this VNet TO remote VNet
# Only created if vnet_peering_config is provided and remote VNet exists
resource "azurerm_virtual_network_peering" "local_to_remote" {
  count                     = var.vnet_peering_config != null ? 1 : 0
  name                      = local.peering_name
  resource_group_name       = var.resource_group.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = var.vnet_peering_config.remote_virtual_network_id
}