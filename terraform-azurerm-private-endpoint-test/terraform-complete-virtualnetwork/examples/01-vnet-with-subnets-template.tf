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
  system_name = "webapp"
  environment = "dev"
}

resource "azurerm_resource_group" "example" {
  name     = "${local.system_name}-rg-example"
  location = "norwayeast"
}

module "basic_vnet" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  # Template naming - change system_name to match your application
  vnet_canonical_name = "${local.system_name}-${local.environment}-vnet"
  system_name         = local.system_name
  environment         = local.environment
  resource_group      = azurerm_resource_group.example
  address_space       = [cidrsubnet("10.0.0.0/16", 8, 1)]  # 10.0.1.0/24
  
  subnet_configs = {
    "frontend" = cidrsubnet("10.0.0.0/16", 10, 4)   # 10.0.1.0/26 - 64 IPs
    "backend"  = cidrsubnet("10.0.0.0/16", 10, 5)   # 10.0.1.64/26 - 64 IPs
  }
  
  tags = {
    Environment = local.environment
    Project     = "Basic VNet Example"
    Purpose     = "Simple networking foundation"
  }
}

# Outputs - demonstrate basic VNet capabilities
output "vnet_id" {
  description = "The ID of the created VNet"
  value       = module.basic_vnet.vnet_id
}

output "vnet_name" {
  description = "The name of the created VNet"
  value       = module.basic_vnet.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.basic_vnet.subnet_ids
}

output "subnet_cidrs" {
  description = "Map of subnet names to their CIDR blocks"
  value       = module.basic_vnet.subnet_cidrs
}

output "network_summary" {
  description = "Complete network configuration summary"
  value       = module.basic_vnet.network_summary
}