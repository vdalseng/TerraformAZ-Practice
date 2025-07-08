locals {
  standard_name = var.name_override != "" ? var.name_override : "${var.system_name}-${var.environment}"
  vnet          = concat(azurerm_virtual_network.vnet.*, [null])[0]
  subnet        = concat(azurerm_subnet.subnet.*, [null])
  subnet_count  = length(azurerm_subnet.subnet)
  
  # Merges user-defined and service-provided DNS zones from private_endpoint_configs for accurate DNS resolution.
  # Ensures each private endpoint config has a complete DNS zone mapping.
  custom_dns_mappings = merge([
    for pe_key, pe_config in var.private_endpoint_configs : {
      for idx, subresource in pe_config.subresource_names :
      subresource => regex("([^/]+)$", pe_config.private_dns_zone_group.private_dns_zone_ids[idx])[0]
      if pe_config.private_dns_zone_group != null && 
         length(try(pe_config.private_dns_zone_group.private_dns_zone_ids, [])) > idx
    }
  ]...)
    
  all_mappings = merge(local.service_dns_zones, local.custom_dns_mappings)
  
  auto_zones = toset(flatten([
    for pe_key, pe_config in var.private_endpoint_configs : [
      for subresource in pe_config.subresource_names :
      lookup(local.all_mappings, subresource, null)
      if lookup(local.all_mappings, subresource, null) != null && 
          pe_config.private_dns_zone_group == null
    ]
  ]))
  
  standardized_zone_names = {
    for zone_name in local.auto_zones :
    replace(zone_name, ".", "_") => zone_name
  }
  
  # Only create DNS zones if create_dns_zones is true
  dns_zones_to_create = var.create_dns_zones ? local.standardized_zone_names : {}
  
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

resource "vault_generic_secret" "kv_info" {
  path      = "${var.system_name}/kv/info/vnet/${var.vnet_canonical_name}"
  data_json = <<EOT
{
  "vnet-id":   "${azurerm_virtual_network.vnet.id}",
  "secret-path": "${var.system_name}/kv/vnet/${var.vnet_canonical_name}",
  "vnet-name": "${azurerm_virtual_network.vnet.name}",
  "vnet-location": "${azurerm_virtual_network.vnet.location}"
}
EOT

}

resource "vault_generic_secret" "kv_secret" {
  for_each  = azurerm_subnet.subnet
  path      = "${var.system_name}/kv/subnet/${each.key}"
  data_json = <<EOT
{
  "vnet-subnets": "${each.value.id}"
}
EOT

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
        local.dns_zone_ids[replace(lookup(merge(local.service_dns_zones, local.all_mappings), subresource, ""), ".", "_")]
      if lookup(merge(local.service_dns_zones, local.all_mappings), subresource, null) != null
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

# VNet links for locally created DNS zones
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_dns_links" {
  for_each = local.dns_zones_to_create

  name                  = "${local.standard_name}-${each.key}-link"
  resource_group_name   = var.resource_group.name
  private_dns_zone_name = each.value
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = var.tags
}