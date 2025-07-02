# 🌐 Example root configuration using the VNet module
# This demonstrates centralized configuration via terraform.tfvars

# 📍 Locals for computed values and tag merging
locals {
  # Merge base tags with additional tags from terraform.tfvars
  common_tags = merge(
    {
      Environment = var.environment
      System      = var.system_name
      Purpose     = "VNet Module Demo"
    },
    var.additional_tags
  )
}

# 📦 Example resource group using centralized location
resource "azurerm_resource_group" "example" {
  name     = "rg-${var.system_name}-${var.environment}"
  location = var.location

  tags = local.common_tags
}

# 🌐 VNet module usage with centralized configuration
module "vnet" {
  source = "./modules/terraform-azurerm-virtualnetwork"

  # ✅ Required variables - all sourced from terraform.tfvars
  vnet_canonical_name = var.system_name
  system_name         = var.system_name
  environment         = var.environment
  resource_group      = azurerm_resource_group.example  # Pass the resource group object

  # 🌐 Network configuration from terraform.tfvars
  address_space = [var.vnet_address_space]

  # 📊 Subnets with calculated CIDR blocks (/25 subnets from /23 network)
  subnet_configs = {
    frontend  = cidrsubnet(var.vnet_address_space, 2, 0) # 10.133.100.0/25
    backend   = cidrsubnet(var.vnet_address_space, 2, 1) # 10.133.100.128/25
    endpoints = cidrsubnet(var.vnet_address_space, 2, 2) # 10.133.101.0/25
  }

  # 🛡️ NSG configuration - attach to application subnets (not endpoints)
  nsg_attached_subnets = ["frontend", "backend"]

  # 🔒 Basic NSG rules for 3-tier architecture
  nsg_rules = {
    allow_web_inbound = {
      priority                     = 100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_ranges           = ["*"]
      destination_port_ranges      = ["80", "443"]
      source_address_prefixes      = ["Internet"]
      destination_address_prefixes = ["frontend"]
    }
    allow_backend_from_frontend = {
      priority                     = 110
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_ranges           = ["*"]
      destination_port_ranges      = ["8080", "8443"]
      source_address_prefixes      = ["frontend"]
      destination_address_prefixes = ["backend"]
    }
  }

  # 🔗 Example configurations (commented - no actual resources to connect)
  # 🔌 Private endpoint configs - uncomment when you have actual resources
  # private_endpoint_configs = {
  #   storage_blob = {
  #     subnet_name         = "endpoints"
  #     resource_id         = azurerm_storage_account.example.id
  #     subresource_names   = ["blob"]
  #   }
  #   key_vault = {
  #     subnet_name         = "endpoints"
  #     resource_id         = azurerm_key_vault.example.id
  #     subresource_names   = ["vault"]
  #   }
  # }

  # 🌐 VNet peering configs - uncomment when you have target VNets
  # vnet_peering_configs = {
  #   to_hub_vnet = {
  #     remote_vnet_name = "hub-vnet"
  #     remote_rg_name   = "rg-hub-prod"
  #     bidirectional    = false
  #     
  #     dns_forwarding = {
  #       enabled                 = true
  #       import_remote_dns_zones = true
  #       export_local_dns_zones  = false
  #     }
  #   }
  # }

  # 🏷️ Use centralized tags
  tags = local.common_tags
}
