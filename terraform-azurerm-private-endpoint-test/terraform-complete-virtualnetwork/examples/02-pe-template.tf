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
  system_name = "someapp"
  environment = "dev"
}

data "azurerm_client_config" "current" {}
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "example" {
  name     = "${local.system_name}-rg-example"
  location = "norwayeast"
}

# Storage account with template naming
resource "azurerm_storage_account" "example" {
  name                          = "${replace(local.system_name, "-", "")}sa${random_string.suffix.result}"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
}

# Key Vault with template naming
resource "azurerm_key_vault" "example" {
  name                          = "${local.system_name}-kv-${random_string.suffix.result}"
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = false
}

module "vnet_with_pe" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  # Template naming - change system_name to match your application
  vnet_canonical_name = "${local.system_name}-${local.environment}-vnet"
  system_name         = local.system_name
  environment         = local.environment
  resource_group      = azurerm_resource_group.example
  address_space       = [cidrsubnet("10.0.0.0/16", 8, 2)]  # 10.0.2.0/24
  
  subnet_configs = {
    "application"       = cidrsubnet("10.0.0.0/16", 10, 8)   # 10.0.2.0/26 - 64 IPs
    "private-endpoints" = cidrsubnet("10.0.0.0/16", 10, 9)   # 10.0.2.64/26 - 64 IPs
  }
  
  # Multiple private endpoints with automatic DNS zone creation
  private_endpoint_configs = {
    "storage-blob" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_storage_account.example.id
      subresource_names = ["blob"]
      # DNS zone automatically created: privatelink.blob.core.windows.net
    }
    "storage-file" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_storage_account.example.id
      subresource_names = ["file"]  
      # DNS zone automatically created: privatelink.file.core.windows.net
    }
    "keyvault" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_key_vault.example.id
      subresource_names = ["vault"]
      # DNS zone automatically created: privatelink.vaultcore.azure.net
    }
  }
  
  tags = {
    Environment = local.environment
    Project     = "Private Endpoint Example"
    Purpose     = "Demonstrate automatic DNS zone creation"
  }
}

# Outputs demonstrating automatic DNS zone creation and private endpoint management
output "private_endpoint_ips" {
  description = "Private IP addresses of all private endpoints"
  value       = module.vnet_with_pe.private_endpoint_ips
}

output "dns_zones_created" {
  description = "DNS zones automatically created for private endpoints"
  value       = module.vnet_with_pe.private_dns_zone_names
}

output "dns_zone_details" {
  description = "Detailed DNS zone information"
  value       = module.vnet_with_pe.private_dns_zone_ids
}

output "network_summary" {
  description = "Complete network configuration summary"
  value       = module.vnet_with_pe.network_summary
}

output "private_endpoint_fqdns" {
  description = "Example FQDNs that can be resolved within this VNet"
  value = {
    storage_blob_fqdn = "${azurerm_storage_account.example.name}.blob.core.windows.net"
    storage_file_fqdn = "${azurerm_storage_account.example.name}.file.core.windows.net"  
    keyvault_fqdn     = "${azurerm_key_vault.example.name}.vault.azure.net"
  }
}