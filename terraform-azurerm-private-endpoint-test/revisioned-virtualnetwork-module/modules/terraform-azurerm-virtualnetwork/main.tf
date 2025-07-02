locals {
  standard_name = var.name_override != "" ? var.name_override : "${var.system_name}-${var.environment}"

  peering_names = var.vnet_peering_configs != null ? {
    for key, config in var.vnet_peering_configs :
    key => "${local.standard_name}-to-${config.remote_vnet_name}"
  } : {}

  remote_zones_to_discover = var.vnet_peering_configs != null ? merge([
    for peering_key, peering_config in var.vnet_peering_configs : {
      for zone_name in values(local.service_dns_zones) :
      "${peering_key}-${replace(zone_name, ".", "_")}" => {
        zone_name           = zone_name
        resource_group_name = peering_config.remote_rg_name
        peering_key         = peering_key
        remote_vnet_name    = peering_config.remote_vnet_name
      }
      if peering_config.dns_forwarding.enabled && peering_config.dns_forwarding.import_remote_zones
    }
  ]...) : {}

  auto_dns_zones = {
    for zone_name in toset(flatten([
      for pe_key, pe_config in var.private_endpoint_configs : [
        for subresource in pe_config.subresource_names :
        lookup(local.service_dns_zones, subresource, null)
        if lookup(local.service_dns_zones, subresource, null) != null && pe_config.private_dns_zone_group == null
      ]
    ])) : replace(zone_name, ".", "_") => zone_name
  }
}

data "azurerm_virtual_network" "remote_vnets" {
  for_each = var.vnet_peering_configs != null ? var.vnet_peering_configs : {}

  name                = each.value.remote_vnet_name
  resource_group_name = each.value.remote_rg_name
}

data "azurerm_private_dns_zone" "remote_dns_zones" {
  for_each = local.remote_zones_to_discover

  name                = each.value.zone_name
  resource_group_name = each.value.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.standard_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id != null ? [1] : []
    content {
      id     = var.ddos_protection_plan_id
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


####### Private DNS Zones
resource "azurerm_private_dns_zone" "private_dns_zone" {
  for_each            = local.auto_dns_zones
  name                = each.value
  resource_group_name = var.resource_group.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "local_dns_links" {
  for_each = local.auto_dns_zones

  name                  = "${local.standard_name}-${each.key}-link"
  resource_group_name   = var.resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone[each.key].name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = var.tags
}

# Import DNS zones from remote VNets (when they allow it)
resource "azurerm_private_dns_zone_virtual_network_link" "import_remote_dns" {
  for_each = {
    for key, zone_info in local.remote_zones_to_discover :
    key => zone_info
    if can(data.azurerm_private_dns_zone.remote_dns_zones[key].id)
  }

  name                  = "${local.standard_name}-import-${each.key}"
  resource_group_name   = each.value.resource_group_name
  private_dns_zone_name = each.value.zone_name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags = merge(var.tags, {
    "LinkType" = "imported"
    "SourceVNet" = each.value.remote_vnet_name
  })
}

####### Private Endpoint
resource "azurerm_private_endpoint" "private_endpoint" {
  for_each            = var.private_endpoint_configs
  name                = "${local.standard_name}-${each.key}-pe"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  subnet_id           = azurerm_subnet.subnet[each.value.subnet_name].id

  private_service_connection {
    name                           = "${local.standard_name}-${each.key}-connection"
    private_connection_resource_id = each.value.resource_id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = false
  }
}



####### Peering
resource "azurerm_virtual_network_peering" "local_to_remotes" {
  for_each = coalesce(var.vnet_peering_configs, {})

  name                      = "${local.standard_name}-to-${each.value.remote_vnet_name}"
  resource_group_name       = var.resource_group.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.remote_vnets[each.key].id

  allow_virtual_network_access  = true
  allow_forwarded_traffic       = true
  allow_gateway_transit         = false
  use_remote_gateways           = false
}