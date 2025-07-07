# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Data sources for shared resources from other teams
data "azurerm_storage_account" "team_a_storage" {
  name                = "teamastorageaccount"
  resource_group_name = "rg-team-a-resources"
}

# Data source for shared DNS zones (if teams want to share DNS management)
data "azurerm_private_dns_zone" "shared_blob_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "rg-team-a-dns"
}

resource "azurerm_resource_group" "advanced" {
  name     = "rg-advanced-vnet-dev"
  location = "Norway East"
}

# Storage Account with auto DNS discovery
resource "azurerm_storage_account" "storage_account" {
  name                     = "stadvancedautodev001"
  resource_group_name      = azurerm_resource_group.advanced.name
  location                 = azurerm_resource_group.advanced.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  public_network_access_enabled = false
  
  tags = {
    environment = "dev"
    purpose     = "auto-dns-example"
  }
}

# SQL Server with auto DNS discovery
resource "azurerm_mssql_server" "mysql_server" {
  name                         = "sql-advanced-auto-dev"
  resource_group_name          = azurerm_resource_group.advanced.name
  location                     = azurerm_resource_group.advanced.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd123!"
  
  public_network_access_enabled = false
  
  tags = {
    environment = "dev"
    purpose     = "auto-dns-example"
  }
}

# Key Vault with manual DNS configuration
resource "azurerm_key_vault" "kv" {
  name                = "kv-advanced-manual-dev"
  location            = azurerm_resource_group.advanced.location
  resource_group_name = azurerm_resource_group.advanced.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  
  public_network_access_enabled = false
  
  tags = {
    environment = "dev"
    purpose     = "manual-dns-example"
  }
}

module "vnet" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "advanced-vnet"
  system_name         = "advanced"
  environment         = "dev"
  resource_group      = azurerm_resource_group.advanced
  address_space       = ["10.2.0.0/16"]
  dns_servers         = ["168.63.129.16"] # Azure recursive resolver
  
  subnet_configs = {
    workloads     = cidrsubnet("10.2.0.0/16", 8, 1)
    endpoints     = cidrsubnet("10.2.0.0/16", 8, 2)
    management    = cidrsubnet("10.2.0.0/16", 8, 3)
    databases     = cidrsubnet("10.2.0.0/16", 8, 4)
  }

  nsg_attached_subnets = ["workloads", "management"]
  
  # NSG rules for enhanced security
  nsg_rules = {
    allow_internal_http = {
      priority                     = 100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_ranges           = ["*"]
      destination_port_ranges      = ["80", "443"]
      source_address_prefixes      = ["workloads"]
      destination_address_prefixes = ["workloads"]
    }
    allow_sql_from_workloads = {
      priority                     = 110
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_ranges           = ["*"]
      destination_port_ranges      = ["1433"]
      source_address_prefixes      = ["workloads"]
      destination_address_prefixes = ["databases"]
    }
    deny_internet_outbound = {
      priority                     = 200
      direction                    = "Outbound"
      access                       = "Deny"
      protocol                     = "*"
      source_port_ranges           = ["*"]
      destination_port_ranges      = ["*"]
      source_address_prefixes      = ["*"]
      destination_address_prefixes = ["Internet"]
    }
  }

 
  private_endpoint_configs = {
    # Local resources with AUTO DNS discovery
    storage_blob_local = {
      subnet_name       = "endpoints"
      resource_id       = azurerm_storage_account.storage_account.id
      subresource_names = ["blob"]
    }
    
    storage_file_local = {
      subnet_name       = "endpoints"
      resource_id       = azurerm_storage_account.storage_account.id
      subresource_names = ["file"]
    }
    
    sql_server_local = {
      subnet_name       = "databases"
      resource_id       = azurerm_mssql_server.mysql_server.id
      subresource_names = ["sqlServer"]
    }
    
    # Key Vault with MANUAL DNS configuration
    key_vault_manual = {
      subnet_name       = "endpoints"
      resource_id       = azurerm_key_vault.kv.id
      subresource_names = ["vault"]
      
      # Manual DNS zone group for services not in service_dns_zones mapping
      private_dns_zone_group = {
        name = "keyvault-manual-dns-group"
        private_dns_zone_ids = [
          "privatelink.vaultcore.azure.net"
        ]
      }
    }
    
    # Shared resources from other teams (using data sources)
    shared_team_a_storage = {
      subnet_name       = "endpoints"
      resource_id       = data.azurerm_storage_account.team_a_storage.id
      subresource_names = ["blob"]
    }
  }
  
  # Shared DNS zones - using data source for shared DNS management
  shared_dns_zone_ids = {
    privatelink_blob_core_windows_net = data.azurerm_private_dns_zone.shared_blob_zone.id
  }
  
  tags = {
    environment = "dev"
    purpose     = "advanced-networking-example"
    dns_pattern = "shared-dns-zones"
    team_access = "cross-team-resource-sharing"
  }
}