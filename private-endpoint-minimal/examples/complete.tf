# ==============================================================================
# EXAMPLE: Complete Private Endpoint Setup for Multiple Teams
# ==============================================================================
# This example demonstrates how to use the minimal private endpoint module
# for different Azure services across multiple teams
# ==============================================================================

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Variables
variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "private-endpoint-example-rg"
}

# ==============================================================================
# FOUNDATIONAL RESOURCES
# ==============================================================================

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet for Private Endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                                          = "private-endpoints"
  resource_group_name                          = azurerm_resource_group.example.name
  virtual_network_name                         = azurerm_virtual_network.main.name
  address_prefixes                             = ["10.0.1.0/24"]
  private_endpoint_network_policies            = "Disabled"
}

# ==============================================================================
# PRIVATE DNS ZONES
# ==============================================================================

# Storage Account DNS Zones
resource "azurerm_private_dns_zone" "storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "storage_file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

# Key Vault DNS Zone
resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.example.name
}

# DNS Zone Virtual Network Links
resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob" {
  name                  = "storage-blob-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_file" {
  name                  = "storage-file-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_file.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "keyvault-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
}

# ==============================================================================
# TARGET RESOURCES
# ==============================================================================

# Storage Account for Team Data
resource "azurerm_storage_account" "team_data" {
  name                     = "teamdatastg${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Security: Disable public access
  public_network_access_enabled = false
  
  tags = {
    Team = "Data"
  }
}

# Storage Account for Application
resource "azurerm_storage_account" "application" {
  name                     = "appstg${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Security: Disable public access
  public_network_access_enabled = false
  
  tags = {
    Team = "Application"
  }
}

# For the Key Vault shared resource
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "shared" {
  name                = "shared-kv-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  
  # Security: Disable public access
  public_network_access_enabled = false
  
  tags = {
    Team = "Security"
  }
}

# Random suffix for unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ==============================================================================
# PRIVATE ENDPOINTS USING THE MODULE
# ==============================================================================

# Team Data Storage - Blob Private Endpoint
module "team_data_storage_blob_pe" {
  source = "../"  # Reference to the parent module

  name                = "teamdata-storage-blob-pe"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  target_resource_id  = azurerm_storage_account.team_data.id
  subresource_names   = ["blob"]
  private_dns_zone_id = azurerm_private_dns_zone.storage_blob.id

  tags = {
    Team        = "Data"
    Environment = "Example"
    Purpose     = "DataLake"
  }
}

# Application Storage - Blob Private Endpoint
module "app_storage_blob_pe" {
  source = "../"

  name                = "app-storage-blob-pe"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  target_resource_id  = azurerm_storage_account.application.id
  subresource_names   = ["blob"]
  private_dns_zone_id = azurerm_private_dns_zone.storage_blob.id

  tags = {
    Team        = "Application"
    Environment = "Example"
    Service     = "WebApp"
  }
}

# Application Storage - File Private Endpoint
module "app_storage_file_pe" {
  source = "../"

  name                = "app-storage-file-pe"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  target_resource_id  = azurerm_storage_account.application.id
  subresource_names   = ["file"]
  private_dns_zone_id = azurerm_private_dns_zone.storage_file.id

  tags = {
    Team        = "Application"
    Environment = "Example"
    Service     = "WebApp"
  }
}

# Shared Key Vault Private Endpoint
module "shared_keyvault_pe" {
  source = "../"

  name                = "shared-keyvault-pe"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  target_resource_id  = azurerm_key_vault.shared.id
  subresource_names   = ["vault"]
  private_dns_zone_id = azurerm_private_dns_zone.key_vault.id

  tags = {
    Team        = "Security"
    Environment = "Example"
    Purpose     = "SecretManagement"
  }
}

# ==============================================================================
# OUTPUTS
# ==============================================================================

output "private_endpoints" {
  description = "Private endpoint details for all services"
  value = {
    team_data_storage_blob = {
      id                = module.team_data_storage_blob_pe.private_endpoint_id
      name              = module.team_data_storage_blob_pe.private_endpoint_name
      private_ip        = module.team_data_storage_blob_pe.private_ip_address
      network_interface = module.team_data_storage_blob_pe.network_interface_id
    }
    app_storage_blob = {
      id                = module.app_storage_blob_pe.private_endpoint_id
      name              = module.app_storage_blob_pe.private_endpoint_name
      private_ip        = module.app_storage_blob_pe.private_ip_address
      network_interface = module.app_storage_blob_pe.network_interface_id
    }
    app_storage_file = {
      id                = module.app_storage_file_pe.private_endpoint_id
      name              = module.app_storage_file_pe.private_endpoint_name
      private_ip        = module.app_storage_file_pe.private_ip_address
      network_interface = module.app_storage_file_pe.network_interface_id
    }
    shared_keyvault = {
      id                = module.shared_keyvault_pe.private_endpoint_id
      name              = module.shared_keyvault_pe.private_endpoint_name
      private_ip        = module.shared_keyvault_pe.private_ip_address
      network_interface = module.shared_keyvault_pe.network_interface_id
    }
  }
}

output "dns_zones" {
  description = "Private DNS zone information"
  value = {
    storage_blob_zone = azurerm_private_dns_zone.storage_blob.name
    storage_file_zone = azurerm_private_dns_zone.storage_file.name
    key_vault_zone    = azurerm_private_dns_zone.key_vault.name
  }
}

output "target_resources" {
  description = "Target resource information"
  value = {
    team_data_storage = {
      id   = azurerm_storage_account.team_data.id
      name = azurerm_storage_account.team_data.name
    }
    application_storage = {
      id   = azurerm_storage_account.application.id
      name = azurerm_storage_account.application.name
    }
    shared_keyvault = {
      id   = azurerm_key_vault.shared.id
      name = azurerm_key_vault.shared.name
    }
  }
}
