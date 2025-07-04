locals {
  standard_name = var.name_override != "" ? var.name_override : "${var.system_name}-${var.environment}"
  
  # Automatically determine DNS zones needed for private endpoints
  auto_dns_zones = {
    for zone_name in toset(flatten([
      for pe_key, pe_config in var.private_endpoint_configs : [
        for subresource in pe_config.subresource_names :
        lookup(local.service_dns_zones, subresource, null)
        if lookup(local.service_dns_zones, subresource, null) != null && pe_config.private_dns_zone_group == null
      ]
    ])) : replace(zone_name, ".", "_") => zone_name
  }
  
  # Only create DNS zones if create_dns_zones is true
  dns_zones_to_create = var.create_dns_zones ? local.auto_dns_zones : {}
  
  # Use either created DNS zones or shared ones
  dns_zone_ids = merge(
    { for k, v in azurerm_private_dns_zone.private_dns_zone : k => v.id },
    var.shared_dns_zone_ids
  )
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

  # Automatically create DNS zone group if no custom one is provided
  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_group == null ? [1] : []
    content {
      name = "${local.standard_name}-${each.key}-dns-group"
      private_dns_zone_ids = [
        for subresource in each.value.subresource_names :
        local.dns_zone_ids[replace(lookup(local.service_dns_zones, subresource, ""), ".", "_")]
        if lookup(local.service_dns_zones, subresource, null) != null
      ]
    }
  }

  # Use custom DNS zone group if provided
  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_group != null ? [each.value.private_dns_zone_group] : []
    content {
      name                 = private_dns_zone_group.value.name
      private_dns_zone_ids = private_dns_zone_group.value.private_dns_zone_ids
    }
  }
}

####### Private DNS Zones for Private Endpoints
resource "azurerm_private_dns_zone" "private_dns_zone" {
  for_each            = local.dns_zones_to_create
  name                = each.value
  resource_group_name = var.resource_group.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_dns_links" {
  for_each = local.auto_dns_zones

  name                  = "${local.standard_name}-${each.key}-link"
  resource_group_name   = var.resource_group.name
  private_dns_zone_name = each.value
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = var.tags
}