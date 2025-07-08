terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Local variables for consistent naming
locals {
  webapp_system_name  = "webapp"
  apiapp_system_name  = "apiapp"
  dataapp_system_name = "dataapp"
  environment         = "dev"
}

# Resource Groups for completely separate applications
resource "azurerm_resource_group" "webapp_rg" {
  name     = "${local.webapp_system_name}-rg-${local.environment}"
  location = "norwayeast"
}

resource "azurerm_resource_group" "apiapp_rg" {
  name     = "${local.apiapp_system_name}-rg-${local.environment}"
  location = "norwayeast"
}

resource "azurerm_resource_group" "dataapp_rg" {
  name     = "${local.dataapp_system_name}-rg-${local.environment}"
  location = "westeurope"
}

# WebApp resources - Frontend application with storage
resource "azurerm_storage_account" "webapp_storage" {
  name                          = "${replace(local.webapp_system_name, "-", "")}sa${random_string.suffix.result}"
  resource_group_name           = azurerm_resource_group.webapp_rg.name
  location                      = azurerm_resource_group.webapp_rg.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
}

# APIApp resources - API services with Key Vault
resource "azurerm_key_vault" "apiapp_keyvault" {
  name                          = "${local.apiapp_system_name}-kv-${random_string.suffix.result}"
  location                      = azurerm_resource_group.apiapp_rg.location
  resource_group_name           = azurerm_resource_group.apiapp_rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = false
}

# DataApp resources - Data services with PostgreSQL
resource "azurerm_postgresql_server" "dataapp_database" {
  name                = "${local.dataapp_system_name}-psql-${random_string.suffix.result}"
  location            = azurerm_resource_group.dataapp_rg.location
  resource_group_name = azurerm_resource_group.dataapp_rg.name

  administrator_login          = "psqladmin"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_1"
  version    = "11"
  storage_mb = 5120

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  public_network_access_enabled    = false
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

data "azurerm_client_config" "current" {}

# WebApp VNet - Frontend application with storage services
module "webapp_vnet" {
  source = "../modules/terraform-azurerm-virtualnetwork"

  vnet_canonical_name = "${local.webapp_system_name}-${local.environment}-vnet"
  system_name         = local.webapp_system_name
  environment         = local.environment
  resource_group      = azurerm_resource_group.webapp_rg
  address_space       = [cidrsubnet("10.0.0.0/16", 8, 20)] # 10.0.20.0/24

  subnet_configs = {
    "web"               = cidrsubnet("10.0.0.0/16", 10, 80) # 10.0.20.0/26 - 64 IPs
    "app"               = cidrsubnet("10.0.0.0/16", 10, 81) # 10.0.20.64/26 - 64 IPs
    "private-endpoints" = cidrsubnet("10.0.0.0/16", 10, 82) # 10.0.20.128/26 - 64 IPs
  }

  # WebApp storage with private endpoints
  private_endpoint_configs = {
    "webapp-storage-blob" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_storage_account.webapp_storage.id
      subresource_names = ["blob"]
    }
    "webapp-storage-file" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_storage_account.webapp_storage.id
      subresource_names = ["file"]
    }
  }

  # Peer with APIApp and DataApp VNets for cross-application communication
  vnet_peering_configs = {
    "to-apiapp" = {
      remote_vnet_name = "${local.apiapp_system_name}-${local.environment}-vnet"
      remote_rg_name   = azurerm_resource_group.apiapp_rg.name
      bidirectional    = true

      dns_forwarding = {
        enabled             = true
        import_remote_zones = true # Access APIApp's Key Vault
        export_local_zones  = true # Share WebApp storage with APIApp
      }
    }
    "to-dataapp" = {
      remote_vnet_name = "${local.dataapp_system_name}-${local.environment}-vnet"
      remote_rg_name   = azurerm_resource_group.dataapp_rg.name
      bidirectional    = true

      dns_forwarding = {
        enabled             = true
        import_remote_zones = true # Access DataApp's database
        export_local_zones  = true # Share WebApp storage with DataApp
      }
    }
  }

  tags = {
    Environment = local.environment
    Application = "WebApp"
    Role        = "Frontend"
    Project     = "Complete Multi-App Example"
  }
}

# APIApp VNet - API services with Key Vault
module "apiapp_vnet" {
  source = "../modules/terraform-azurerm-virtualnetwork"

  vnet_canonical_name = "${local.apiapp_system_name}-${local.environment}-vnet"
  system_name         = local.apiapp_system_name
  environment         = local.environment
  resource_group      = azurerm_resource_group.apiapp_rg
  address_space       = [cidrsubnet("10.0.0.0/16", 8, 21)] # 10.0.21.0/24

  subnet_configs = {
    "api"               = cidrsubnet("10.0.0.0/16", 10, 84) # 10.0.21.0/26 - 64 IPs
    "app"               = cidrsubnet("10.0.0.0/16", 10, 85) # 10.0.21.64/26 - 64 IPs
    "private-endpoints" = cidrsubnet("10.0.0.0/16", 10, 86) # 10.0.21.128/26 - 64 IPs
  }

  # APIApp Key Vault with private endpoint
  private_endpoint_configs = {
    "apiapp-keyvault" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_key_vault.apiapp_keyvault.id
      subresource_names = ["vault"]
    }
  }

  # Peer with WebApp and DataApp for cross-application communication
  vnet_peering_configs = {
    "to-webapp" = {
      remote_vnet_name = module.webapp_vnet.vnet_name
      remote_rg_name   = azurerm_resource_group.webapp_rg.name
      bidirectional    = true

      dns_forwarding = {
        enabled             = true
        import_remote_zones = true # Access WebApp's storage
        export_local_zones  = true # Share APIApp Key Vault with WebApp
      }
    }
    "to-dataapp" = {
      remote_vnet_name = "${local.dataapp_system_name}-${local.environment}-vnet"
      remote_rg_name   = azurerm_resource_group.dataapp_rg.name
      bidirectional    = true

      dns_forwarding = {
        enabled             = true
        import_remote_zones = true # Access DataApp's database
        export_local_zones  = true # Share APIApp Key Vault with DataApp
      }
    }
  }

  tags = {
    Environment = local.environment
    Application = "APIApp"
    Role        = "API Services"
    Project     = "Complete Multi-App Example"
  }
}

# DataApp VNet - Data services with PostgreSQL database
module "dataapp_vnet" {
  source = "../modules/terraform-azurerm-virtualnetwork"

  vnet_canonical_name = "${local.dataapp_system_name}-${local.environment}-vnet"
  system_name         = local.dataapp_system_name
  environment         = local.environment
  resource_group      = azurerm_resource_group.dataapp_rg
  address_space       = [cidrsubnet("10.0.0.0/16", 8, 22)] # 10.0.22.0/24

  subnet_configs = {
    "data"              = cidrsubnet("10.0.0.0/16", 10, 88) # 10.0.22.0/26 - 64 IPs
    "app"               = cidrsubnet("10.0.0.0/16", 10, 89) # 10.0.22.64/26 - 64 IPs
    "private-endpoints" = cidrsubnet("10.0.0.0/16", 10, 90) # 10.0.22.128/26 - 64 IPs
  }

  # DataApp PostgreSQL database with private endpoint
  private_endpoint_configs = {
    "dataapp-database" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_postgresql_server.dataapp_database.id
      subresource_names = ["postgresqlServer"]
    }
  }

  # Peer with WebApp and APIApp for cross-application communication
  vnet_peering_configs = {
    "to-webapp" = {
      remote_vnet_name = module.webapp_vnet.vnet_name
      remote_rg_name   = azurerm_resource_group.webapp_rg.name
      bidirectional    = true

      dns_forwarding = {
        enabled             = true
        import_remote_zones = true # Access WebApp's storage
        export_local_zones  = true # Share DataApp database with WebApp
      }
    }
    "to-apiapp" = {
      remote_vnet_name = module.apiapp_vnet.vnet_name
      remote_rg_name   = azurerm_resource_group.apiapp_rg.name
      bidirectional    = true

      dns_forwarding = {
        enabled             = true
        import_remote_zones = true # Access APIApp's Key Vault
        export_local_zones  = true # Share DataApp database with APIApp
      }
    }
  }

  tags = {
    Environment = local.environment
    Application = "DataApp"
    Role        = "Data Services"
    Region      = "West Europe"
    Project     = "Complete Multi-App Example"
  }
}

# Comprehensive outputs showing the complete multi-application architecture
output "architecture_summary" {
  description = "Complete multi-application architecture summary"
  value = {
    webapp = {
      vnet_name    = module.webapp_vnet.vnet_name
      vnet_id      = module.webapp_vnet.vnet_id
      pe_ips       = module.webapp_vnet.private_endpoint_ips
      dns_zones    = module.webapp_vnet.private_dns_zone_names
      peering_info = module.webapp_vnet.network_summary.peering
    }
    apiapp = {
      vnet_name    = module.apiapp_vnet.vnet_name
      vnet_id      = module.apiapp_vnet.vnet_id
      pe_ips       = module.apiapp_vnet.private_endpoint_ips
      dns_zones    = module.apiapp_vnet.private_dns_zone_names
      peering_info = module.apiapp_vnet.network_summary.peering
    }
    dataapp = {
      vnet_name    = module.dataapp_vnet.vnet_name
      vnet_id      = module.dataapp_vnet.vnet_id
      pe_ips       = module.dataapp_vnet.private_endpoint_ips
      dns_zones    = module.dataapp_vnet.private_dns_zone_names
      peering_info = module.dataapp_vnet.network_summary.peering
    }
  }
}

output "cross_app_connectivity_matrix" {
  description = "Matrix showing which applications can access which resources"
  value = {
    webapp_can_access = [
      "APIApp Key Vault: ${azurerm_key_vault.apiapp_keyvault.name}.vault.azure.net",
      "DataApp Database: ${azurerm_postgresql_server.dataapp_database.name}.postgres.database.azure.com"
    ]
    apiapp_can_access = [
      "WebApp Storage: ${azurerm_storage_account.webapp_storage.name}.blob.core.windows.net",
      "DataApp Database: ${azurerm_postgresql_server.dataapp_database.name}.postgres.database.azure.com"
    ]
    dataapp_can_access = [
      "WebApp Storage: ${azurerm_storage_account.webapp_storage.name}.blob.core.windows.net",
      "APIApp Key Vault: ${azurerm_key_vault.apiapp_keyvault.name}.vault.azure.net"
    ]
  }
}

output "dns_forwarding_summary" {
  description = "Summary of automatic DNS zone forwarding between separate applications"
  value = {
    total_vnets                 = 3
    total_peering_connections   = 6 # 2 per VNet × 3 VNets = 6 bidirectional connections
    architecture                = "Completely separate applications - no shared services"
    automatic_dns_zones_created = "Each VNet creates zones for its private endpoints"
    automatic_dns_forwarding    = "All VNets can resolve each other's private endpoints"
    security_note               = "All peering requires proper RBAC permissions on target VNets"
    use_case                    = "Three independent applications sharing resources via VNet peering and DNS forwarding"
  }
}
