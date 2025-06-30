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

# Template variables for easy customization
locals {
  app1_system_name = "someapp1"
  app2_system_name = "someapp2"
  environment      = "dev"
}


data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource groups for peer-to-peer VNet architecture  
resource "azurerm_resource_group" "app1_rg" {
  name     = "${local.app1_system_name}-rg-${local.environment}"
  location = "norwayeast"
}

resource "azurerm_resource_group" "app2_rg" {
  name     = "${local.app2_system_name}-rg-${local.environment}"
  location = "norwayeast"
}

# Storage account in App1
resource "azurerm_storage_account" "app1_storage" {
  name                          = "${replace(local.app1_system_name, "-", "")}sa${random_string.suffix.result}"
  resource_group_name           = azurerm_resource_group.app1_rg.name
  location                      = azurerm_resource_group.app1_rg.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
}

# Key Vault in App2
resource "azurerm_key_vault" "app2_keyvault" {
  name                          = "${local.app2_system_name}-kv-${random_string.suffix.result}"
  location                      = azurerm_resource_group.app2_rg.location
  resource_group_name           = azurerm_resource_group.app2_rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = false
}

# App1 VNet with storage services
module "app1_vnet" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "${local.app1_system_name}-${local.environment}-vnet"
  system_name         = local.app1_system_name
  environment         = local.environment
  resource_group      = azurerm_resource_group.app1_rg
  address_space       = [cidrsubnet("10.0.0.0/16", 8, 10)]  # 10.0.10.0/24
  
  subnet_configs = {
    "web"               = cidrsubnet("10.0.0.0/16", 10, 40)  # 10.0.10.0/26 - 64 IPs
    "app"               = cidrsubnet("10.0.0.0/16", 10, 41)  # 10.0.10.64/26 - 64 IPs
    "data"              = cidrsubnet("10.0.0.0/16", 10, 42)  # 10.0.10.128/26 - 64 IPs
    "private-endpoints" = cidrsubnet("10.0.0.0/16", 10, 43)  # 10.0.10.192/26 - 64 IPs
  }
  
  # App1 storage with private endpoints
  private_endpoint_configs = {
    "app1-storage-blob" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_storage_account.app1_storage.id
      subresource_names = ["blob"]
      # Creates: privatelink.blob.core.windows.net
    }
    "app1-storage-file" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_storage_account.app1_storage.id
      subresource_names = ["file"]
      # Creates: privatelink.file.core.windows.net
    }
  }
  
  # Peer with App2 VNet
  vnet_peering_configs = {
    "to-app2" = {
      remote_vnet_name = "${local.app2_system_name}-${local.environment}-vnet"
      remote_rg_name   = azurerm_resource_group.app2_rg.name
      bidirectional    = true  # Creates peering in both directions automatically
      
      dns_forwarding = {
        enabled             = true
        import_remote_zones = true  # Access App2's Key Vault via private DNS
        export_local_zones  = true  # Allow App2 to access App1's storage
      }
    }
  }
  
  tags = {
    Environment = local.environment
    Application = "App1"
    Project     = "Peer-to-Peer VNet Example"
    Purpose     = "Storage services with cross-VNet connectivity"
  }
}

# App2 VNet with security services
module "app2_vnet" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "${local.app2_system_name}-${local.environment}-vnet"
  system_name         = local.app2_system_name
  environment         = local.environment
  resource_group      = azurerm_resource_group.app2_rg
  address_space       = [cidrsubnet("10.0.0.0/16", 8, 11)]  # 10.0.11.0/24
  
  subnet_configs = {
    "api"               = cidrsubnet("10.0.0.0/16", 10, 44)  # 10.0.11.0/26 - 64 IPs
    "app"               = cidrsubnet("10.0.0.0/16", 10, 45)  # 10.0.11.64/26 - 64 IPs
    "mgmt"              = cidrsubnet("10.0.0.0/16", 10, 46)  # 10.0.11.128/26 - 64 IPs
    "private-endpoints" = cidrsubnet("10.0.0.0/16", 10, 47)  # 10.0.11.192/26 - 64 IPs
  }
  
  # App2 Key Vault with private endpoint
  private_endpoint_configs = {
    "app2-keyvault" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_key_vault.app2_keyvault.id
      subresource_names = ["vault"]
      # Creates: privatelink.vaultcore.azure.net
    }
  }
  
  # Peer with App1 VNet
  vnet_peering_configs = {
    "to-app1" = {
      remote_vnet_name = module.app1_vnet.vnet_name
      remote_rg_name   = azurerm_resource_group.app1_rg.name
      bidirectional    = true  # Creates peering in both directions automatically
      
      dns_forwarding = {
        enabled             = true
        import_remote_zones = true  # Access App1's storage via private DNS
        export_local_zones  = true  # Allow App1 to access App2's Key Vault
      }
    }
  }
  
  tags = {
    Environment = local.environment
    Application = "App2"
    Project     = "Peer-to-Peer VNet Example"
    Purpose     = "Security services with cross-VNet connectivity"
  }
}

# Outputs demonstrating peer-to-peer VNet connectivity and DNS forwarding
output "app1_vnet_details" {
  description = "App1 VNet configuration summary"
  value = {
    vnet_id       = module.app1_vnet.vnet_id
    vnet_name     = module.app1_vnet.vnet_name
    address_space = module.app1_vnet.vnet_address_space
    subnet_ids    = module.app1_vnet.subnet_ids
    pe_ips        = module.app1_vnet.private_endpoint_ips
    dns_zones     = module.app1_vnet.private_dns_zone_names
  }
}

output "app2_vnet_details" {
  description = "App2 VNet configuration summary with peering info"
  value = {
    vnet_id       = module.app2_vnet.vnet_id
    vnet_name     = module.app2_vnet.vnet_name
    address_space = module.app2_vnet.vnet_address_space
    subnet_ids    = module.app2_vnet.subnet_ids
    pe_ips        = module.app2_vnet.private_endpoint_ips
    dns_zones     = module.app2_vnet.private_dns_zone_names
    peering_info  = module.app2_vnet.network_summary.peering
  }
}

output "cross_vnet_dns_resolution" {
  description = "Examples of cross-VNet DNS resolution enabled by automatic forwarding"
  value = {
    app1_can_access = [
      "App2 Key Vault: ${azurerm_key_vault.app2_keyvault.name}.vault.azure.net"
    ]
    app2_can_access = [
      "App1 Storage Blob: ${azurerm_storage_account.app1_storage.name}.blob.core.windows.net",
      "App1 Storage File: ${azurerm_storage_account.app1_storage.name}.file.core.windows.net"
    ]
    how_it_works = "DNS zones are automatically shared between peered VNets when dns_forwarding is enabled"
  }
}

output "peering_summary" {
  description = "Summary of peer-to-peer VNet connections"
  value = {
    architecture = "Peer-to-Peer (no hub/spoke hierarchy)"
    bidirectional_peering = "Automatic creation of App1↔App2 peering connections"
    dns_forwarding_enabled = "Private endpoints resolvable across both VNets"
    security_model = "Requires RBAC permissions on target VNets for peering creation"
    total_peering_connections = 2  # One in each direction
    use_case = "Two independent applications sharing resources via VNet peering"
  }
}
