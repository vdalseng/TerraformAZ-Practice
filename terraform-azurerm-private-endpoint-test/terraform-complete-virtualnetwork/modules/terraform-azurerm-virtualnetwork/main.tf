# Data source to verify remote VNet exists and fetch its resource ID
data "azurerm_virtual_network" "remote_vnet" {
  count               = var.vnet_peering_config != null ? 1 : 0
  name                = var.vnet_peering_config.remote_vnet_name
  resource_group_name = var.vnet_peering_config.remote_rg_name
}

locals {
  standard_name = "${var.system_name}-${var.environment}"
  vnet_name = var.name_override != "" ? var.name_override : local.standard_name
  peering_name = var.vnet_peering_config != null ? "${local.vnet_name}-to-${var.vnet_peering_config.remote_vnet_name}" : ""
  
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

# Auto-created DNS zones for private endpoints when not explicitly provided
resource "azurerm_private_dns_zone" "private_dns_zone" {
  for_each            = local.auto_dns_zones
  name                = each.value
  resource_group_name = var.resource_group.name
  tags                = var.tags
}

# Combined DNS zone links - handles local and shared DNS zones
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_links" {
  for_each = merge(
    # Local DNS zones (created by this module)
    {
      for key, zone_name in local.auto_dns_zones : 
      key => {
        name                = "${local.vnet_name}-${key}-link"
        resource_group      = var.resource_group.name
        dns_zone_name       = azurerm_private_dns_zone.private_dns_zone[key].name
        registration_enabled = false
      }
    },
    # Shared DNS zones (externally managed, centralized)
    {
      for key, config in var.shared_dns_zones :
      key => {
        name                = "${local.vnet_name}-to-${key}-link"
        resource_group      = config.dns_zone_rg_name
        dns_zone_name       = config.dns_zone_name
        registration_enabled = config.registration_enabled
      }
    }
  )
  
  name                  = each.value.name
  resource_group_name   = each.value.resource_group
  private_dns_zone_name = each.value.dns_zone_name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = each.value.registration_enabled
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
  # Auto-generate DNS zone group when not explicitly provided
  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_group != null ? [each.value.private_dns_zone_group] : (
      length([
        for sub in each.value.subresource_names : sub 
        if lookup(local.service_dns_zones, sub, null) != null
      ]) > 0 ? [{
        name = "${each.key}-dns-group"
        private_dns_zone_ids = [
          for sub in each.value.subresource_names : 
          azurerm_private_dns_zone.private_dns_zone[replace(lookup(local.service_dns_zones, sub, ""), ".", "_")].id
          if lookup(local.service_dns_zones, sub, null) != null
        ]
      }] : []
    )
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
  remote_virtual_network_id = data.azurerm_virtual_network.remote_vnet[0].id
}