# Data source for multiple remote VNets (enhanced peering)
data "azurerm_virtual_network" "remote_vnets" {
  for_each = var.vnet_peering_configs != null ? var.vnet_peering_configs : {}

  name                = each.value.remote_vnet_name
  resource_group_name = each.value.remote_rg_name
}

# Data source to discover DNS zones in remote VNets for forwarding  
data "azurerm_private_dns_zone" "remote_dns_zones" {
  for_each = local.remote_zones_to_discover

  name                = each.value.zone_name
  resource_group_name = each.value.resource_group_name
}

locals {
  standard_name = "${var.system_name}-${var.environment}"
  vnet_name     = var.name_override != "" ? var.name_override : local.standard_name

  # Enhanced peering names for multiple VNets
  peering_names = var.vnet_peering_configs != null ? {
    for key, config in var.vnet_peering_configs :
    key => "${local.vnet_name}-to-${config.remote_vnet_name}"
  } : {}

  # Collect all remote zones that need to be discovered for DNS forwarding
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

  service_dns_zones = {
    # Storage Account
    "blob"  = "privatelink.blob.core.windows.net"
    "dfs"   = "privatelink.dfs.core.windows.net"
    "file"  = "privatelink.file.core.windows.net"
    "queue" = "privatelink.queue.core.windows.net"
    "table" = "privatelink.table.core.windows.net"
    "web"   = "privatelink.web.core.windows.net"

    # Key Vault
    "vault" = "privatelink.vaultcore.azure.net"

    # SQL Database
    "sqlServer" = "privatelink.database.windows.net"

    # PostgreSQL
    "postgresqlServer" = "privatelink.postgres.database.azure.com"

    # Cosmos DB
    "sql"       = "privatelink.documents.azure.com"
    "mongodb"   = "privatelink.mongo.cosmos.azure.com"
    "cassandra" = "privatelink.cassandra.cosmos.azure.com"
    "gremlin"   = "privatelink.gremlin.cosmos.azure.com"

    # Grafana
    "grafana" = "privatelink.grafana.azure.com"
  }

  # Auto-discover DNS zones needed from private endpoint configs  
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

# Core virtual network resources
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
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

# Auto-created DNS zones for private endpoints when not explicitly provided
resource "azurerm_private_dns_zone" "private_dns_zone" {
  for_each            = local.auto_dns_zones
  name                = each.value
  resource_group_name = var.resource_group.name
  tags                = var.tags
}

# DNS zone links - handles local and remote forwarded DNS zones  
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_links" {
  for_each = merge(
    # Local DNS zones (created by this module)
    {
      for key, zone_name in local.auto_dns_zones :
      "local-${key}" => {
        name                 = "${local.vnet_name}-${key}-link"
        resource_group       = var.resource_group.name
        dns_zone_name        = azurerm_private_dns_zone.private_dns_zone[key].name
        registration_enabled = false
        zone_type            = "local"
      }
    },
    # Remote DNS zones (forwarding from peered VNets)
    {
      for key, zone_info in local.remote_zones_to_discover :
      "remote-${key}" => {
        name                 = "${local.vnet_name}-to-${zone_info.peering_key}-${replace(zone_info.zone_name, ".", "_")}-link"
        resource_group       = zone_info.resource_group_name
        dns_zone_name        = zone_info.zone_name
        registration_enabled = false
        zone_type            = "remote"
      }
      if contains(keys(data.azurerm_private_dns_zone.remote_dns_zones), key)
    }
  )

  name                  = each.value.name
  resource_group_name   = each.value.resource_group
  private_dns_zone_name = each.value.dns_zone_name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = each.value.registration_enabled

  tags = merge(var.tags, {
    "DNSZoneType" = each.value.zone_type
    "VNetName"    = local.vnet_name
  })
}

# Private Endpoints - create for each configuration provided
resource "azurerm_private_endpoint" "private_endpoint" {
  for_each            = var.private_endpoint_configs
  name                = "${local.vnet_name}-${each.key}-pe"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  subnet_id           = azurerm_subnet.subnet[each.value.subnet_name].id

  private_service_connection {
    name                           = "${local.vnet_name}-${each.key}-connection"
    private_connection_resource_id = each.value.resource_id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = false
  }
}

# Enhanced VNet Peering - support for multiple peering connections
resource "azurerm_virtual_network_peering" "local_to_remotes" {
  for_each = var.vnet_peering_configs != null ? var.vnet_peering_configs : {}

  name                      = local.peering_names[each.key]
  resource_group_name       = var.resource_group.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.remote_vnets[each.key].id
}

# Bidirectional peering - FROM remote VNets TO this VNet
resource "azurerm_virtual_network_peering" "remotes_to_local" {
  for_each = {
    for key, config in coalesce(var.vnet_peering_configs, {}) : key => config
    if config.bidirectional
  }

  name                      = "${each.value.remote_vnet_name}-to-${local.vnet_name}"
  resource_group_name       = each.value.remote_rg_name
  virtual_network_name      = each.value.remote_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}

# Export our local DNS zones to remote VNets (when bidirectional and DNS forwarding enabled)
resource "azurerm_private_dns_zone_virtual_network_link" "export_to_remotes" {
  for_each = merge([
    for peering_key, peering_config in coalesce(var.vnet_peering_configs, {}) : {
      for zone_key, zone_name in local.auto_dns_zones :
      "${peering_key}-${zone_key}" => {
        peering_key      = peering_key
        zone_key         = zone_key
        zone_name        = zone_name
        remote_vnet_name = peering_config.remote_vnet_name
        remote_vnet_id   = data.azurerm_virtual_network.remote_vnets[peering_key].id
      }
      if peering_config.bidirectional && peering_config.dns_forwarding.enabled && peering_config.dns_forwarding.export_local_zones
    }
  ]...)

  name                  = "${each.value.remote_vnet_name}-to-${each.value.zone_key}-link"
  resource_group_name   = var.resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone[each.value.zone_key].name
  virtual_network_id    = each.value.remote_vnet_id
  registration_enabled  = false

  tags = merge(var.tags, {
    "DNSZoneType" = "exported"
    "ExportedTo"  = each.value.remote_vnet_name
  })
}