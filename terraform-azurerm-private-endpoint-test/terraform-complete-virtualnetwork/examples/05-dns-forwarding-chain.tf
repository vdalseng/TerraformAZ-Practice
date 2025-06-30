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
  vnet1_system_name = "storage-vnet1"
  vnet2_system_name = "keyvault-vnet2"
  vnet3_system_name = "database-vnet3"
  environment       = "prod"
}

# Resource groups for the VNet chain
resource "azurerm_resource_group" "vnet1_rg" {
  name     = "${local.vnet1_system_name}-rg-${local.environment}"
  location = "norwayeast"
}

resource "azurerm_resource_group" "vnet2_rg" {
  name     = "${local.vnet2_system_name}-rg-${local.environment}"
  location = "norwayeast"
}

resource "azurerm_resource_group" "vnet3_rg" {
  name     = "${local.vnet3_system_name}-rg-${local.environment}"
  location = "westeurope"
}

# Different resources in each VNet to demonstrate DNS forwarding
resource "azurerm_storage_account" "vnet1_storage" {
  name                          = "${replace(local.vnet1_system_name, "-", "")}sa${random_string.suffix.result}"
  resource_group_name           = azurerm_resource_group.vnet1_rg.name
  location                      = azurerm_resource_group.vnet1_rg.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
}

resource "azurerm_key_vault" "vnet2_keyvault" {
  name                          = "${local.vnet2_system_name}-kv-${random_string.suffix.result}"
  location                      = azurerm_resource_group.vnet2_rg.location
  resource_group_name           = azurerm_resource_group.vnet2_rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = false
}

resource "azurerm_postgresql_server" "vnet3_database" {
  name                = "${local.vnet3_system_name}-psql-${random_string.suffix.result}"
  location            = azurerm_resource_group.vnet3_rg.location
  resource_group_name = azurerm_resource_group.vnet3_rg.name

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

# VNet1 - Storage services, connects to VNet2
module "vnet1" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "${local.vnet1_system_name}-${local.environment}-vnet"
  system_name         = local.vnet1_system_name
  environment         = local.environment
  resource_group      = azurerm_resource_group.vnet1_rg
  address_space       = [cidrsubnet("10.0.0.0/16", 8, 30)]  # 10.0.30.0/24
  
  subnet_configs = {
    "application"       = cidrsubnet("10.0.0.0/16", 10, 120)  # 10.0.30.0/26 - 64 IPs
    "private-endpoints" = cidrsubnet("10.0.0.0/16", 10, 121)  # 10.0.30.64/26 - 64 IPs
  }
  
  private_endpoint_configs = {
    "storage-blob" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_storage_account.vnet1_storage.id
      subresource_names = ["blob"]
      # Creates: privatelink.blob.core.windows.net
    }
    "storage-file" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_storage_account.vnet1_storage.id
      subresource_names = ["file"]
      # Creates: privatelink.file.core.windows.net
    }
  }
  
  # Connect to VNet2 only (gets transitive access to VNet3 through VNet2)
  vnet_peering_configs = {
    "to-vnet2" = {
      remote_vnet_name = "${local.vnet2_system_name}-${local.environment}-vnet"
      remote_rg_name   = azurerm_resource_group.vnet2_rg.name
      bidirectional    = true
      
      dns_forwarding = {
        enabled             = true
        import_remote_zones = true  # Access VNet2's Key Vault + forwarded VNet3 zones
        export_local_zones  = true  # VNet2 can access our storage + forward to VNet3
      }
    }
  }
  
  tags = {
    Environment = "Production"
    Service     = "Storage"
    Chain       = "VNet1"
  }
}

# VNet2 - Key Vault services, connects to both VNet1 and VNet3 (central hub in chain)
module "vnet2" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "${local.vnet2_system_name}-${local.environment}-vnet"
  system_name         = local.vnet2_system_name
  environment         = local.environment
  resource_group      = azurerm_resource_group.vnet2_rg
  address_space       = [cidrsubnet("10.0.0.0/16", 8, 31)]  # 10.0.31.0/24
  
  subnet_configs = {
    "api"               = cidrsubnet("10.0.0.0/16", 10, 124)  # 10.0.31.0/26 - 64 IPs
    "private-endpoints" = cidrsubnet("10.0.0.0/16", 10, 125)  # 10.0.31.64/26 - 64 IPs
  }
  
  private_endpoint_configs = {
    "keyvault" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_key_vault.vnet2_keyvault.id
      subresource_names = ["vault"]
      # Creates: privatelink.vaultcore.azure.net
    }
  }
  
  # Connect to both VNet1 and VNet3 (central node in the chain)
  vnet_peering_configs = {
    "to-vnet1" = {
      remote_vnet_name = module.vnet1.vnet_name
      remote_rg_name   = azurerm_resource_group.vnet1_rg.name
      bidirectional    = true
      
      dns_forwarding = {
        enabled             = true
        import_remote_zones = true  # Access VNet1's storage
        export_local_zones  = true  # VNet1 can access our Key Vault
      }
    }
    "to-vnet3" = {
      remote_vnet_name = "${local.vnet3_system_name}-${local.environment}-vnet"
      remote_rg_name   = azurerm_resource_group.vnet3_rg.name
      bidirectional    = true
      
      dns_forwarding = {
        enabled             = true
        import_remote_zones = true  # Access VNet3's database
        export_local_zones  = true  # VNet3 can access our Key Vault
      }
    }
  }
  
  tags = {
    Environment = "Production"
    Service     = "Security/Key Management"
    Chain       = "VNet2 (Central Hub)"
  }
}

# VNet3 - Database services, connects to VNet2 only
module "vnet3" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "${local.vnet3_system_name}-${local.environment}-vnet"
  system_name         = local.vnet3_system_name
  environment         = local.environment
  resource_group      = azurerm_resource_group.vnet3_rg
  address_space       = [cidrsubnet("10.0.0.0/16", 8, 32)]  # 10.0.32.0/24
  
  subnet_configs = {
    "data"              = cidrsubnet("10.0.0.0/16", 10, 128)  # 10.0.32.0/26 - 64 IPs
    "private-endpoints" = cidrsubnet("10.0.0.0/16", 10, 129)  # 10.0.32.64/26 - 64 IPs
  }
  
  private_endpoint_configs = {
    "database" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_postgresql_server.vnet3_database.id
      subresource_names = ["postgresqlServer"]
      # Creates: privatelink.postgres.database.azure.com
    }
  }
  
  # Connect to VNet2 only (gets transitive access to VNet1 through VNet2)
  vnet_peering_configs = {
    "to-vnet2" = {
      remote_vnet_name = module.vnet2.vnet_name
      remote_rg_name   = azurerm_resource_group.vnet2_rg.name
      bidirectional    = true
      
      dns_forwarding = {
        enabled             = true
        import_remote_zones = true  # Access VNet2's Key Vault + forwarded VNet1 zones
        export_local_zones  = true  # VNet2 can access our database + forward to VNet1
      }
    }
  }
  
  tags = {
    Environment = "Production"
    Service     = "Database"
    Chain       = "VNet3"
  }
}

# Outputs demonstrating the DNS forwarding chain
output "dns_chain_summary" {
  description = "Summary of the VNet DNS forwarding chain"
  value = {
    architecture = "VNet1 ↔ VNet2 ↔ VNet3"
    vnet1_can_access = [
      "Own Storage: ${azurerm_storage_account.vnet1_storage.name}.blob.core.windows.net",
      "VNet2 Key Vault: ${azurerm_key_vault.vnet2_keyvault.name}.vault.core.windows.net",
      "VNet3 Database: ${azurerm_postgresql_server.vnet3_database.name}.postgres.database.azure.com (via VNet2)"
    ]
    vnet2_can_access = [
      "VNet1 Storage: ${azurerm_storage_account.vnet1_storage.name}.blob.core.windows.net",
      "Own Key Vault: ${azurerm_key_vault.vnet2_keyvault.name}.vault.core.windows.net",
      "VNet3 Database: ${azurerm_postgresql_server.vnet3_database.name}.postgres.database.azure.com"
    ]
    vnet3_can_access = [
      "VNet1 Storage: ${azurerm_storage_account.vnet1_storage.name}.blob.core.windows.net (via VNet2)",
      "VNet2 Key Vault: ${azurerm_key_vault.vnet2_keyvault.name}.vault.core.windows.net",
      "Own Database: ${azurerm_postgresql_server.vnet3_database.name}.postgres.database.azure.com"
    ]
  }
}

output "peering_connections_created" {
  description = "Summary of all peering connections and DNS forwarding"
  value = {
    total_peering_connections = 6  # 3 bidirectional connections = 6 peering resources
    dns_zones_per_vnet = {
      vnet1 = "2 DNS zones: privatelink.blob.core.windows.net, privatelink.file.core.windows.net"
      vnet2 = "1 DNS zone: privatelink.vaultcore.azure.net"
      vnet3 = "1 DNS zone: privatelink.postgres.database.azure.com"
    }
    automatic_dns_forwarding = "All VNets can resolve each other's private endpoints through the chain"
    security_model = "Each peering requires proper RBAC permissions on target VNets"
  }
}

output "individual_vnet_details" {
  description = "Detailed information about each VNet"
  value = {
    vnet1 = {
      name         = module.vnet1.vnet_name
      id           = module.vnet1.vnet_id
      pe_ips       = module.vnet1.private_endpoint_ips
      dns_zones    = module.vnet1.private_dns_zone_names
      peering_info = module.vnet1.network_summary.peering
    }
    vnet2 = {
      name         = module.vnet2.vnet_name
      id           = module.vnet2.vnet_id
      pe_ips       = module.vnet2.private_endpoint_ips
      dns_zones    = module.vnet2.private_dns_zone_names
      peering_info = module.vnet2.network_summary.peering
    }
    vnet3 = {
      name         = module.vnet3.vnet_name
      id           = module.vnet3.vnet_id
      pe_ips       = module.vnet3.private_endpoint_ips
      dns_zones    = module.vnet3.private_dns_zone_names
      peering_info = module.vnet3.network_summary.peering
    }
  }
}
