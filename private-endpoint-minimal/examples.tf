# ==============================================================================
# EXAMPLE: Using the Minimal Private Endpoint Module
# ==============================================================================
# This example shows how different teams can use the minimal private endpoint 
# module to secure their Azure PaaS services
# ==============================================================================

# Example 1: Storage Account with Blob Private Endpoint
module "team_data_storage_pe" {
  source = "../modules/private-endpoint-minimal"

  name                = "teamdata-storage-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private_endpoints.id
  target_resource_id  = azurerm_storage_account.team_data.id
  subresource_names   = ["blob"]
  private_dns_zone_id = azurerm_private_dns_zone.storage_blob.id

  tags = {
    Team        = "Data"
    Environment = "Production"
    Purpose     = "DataLake"
  }
}

# Example 2: Key Vault Private Endpoint
module "shared_keyvault_pe" {
  source = "../modules/private-endpoint-minimal"

  name                = "shared-keyvault-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private_endpoints.id
  target_resource_id  = azurerm_key_vault.shared.id
  subresource_names   = ["vault"]
  private_dns_zone_id = azurerm_private_dns_zone.key_vault.id

  tags = {
    Team        = "Security"
    Environment = "Production"
    Purpose     = "SecretManagement"
  }
}

# Example 3: Multiple Storage Endpoints (Blob + File)
module "app_storage_blob_pe" {
  source = "../modules/private-endpoint-minimal"

  name                = "app-storage-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private_endpoints.id
  target_resource_id  = azurerm_storage_account.application.id
  subresource_names   = ["blob"]
  private_dns_zone_id = azurerm_private_dns_zone.storage_blob.id

  tags = {
    Team        = "Application"
    Environment = "Production"
    Service     = "WebApp"
  }
}

module "app_storage_file_pe" {
  source = "../modules/private-endpoint-minimal"

  name                = "app-storage-file-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private_endpoints.id
  target_resource_id  = azurerm_storage_account.application.id
  subresource_names   = ["file"]
  private_dns_zone_id = azurerm_private_dns_zone.storage_file.id

  tags = {
    Team        = "Application"
    Environment = "Production"
    Service     = "WebApp"
  }
}

# ==============================================================================
# SUPPORTING RESOURCES
# ==============================================================================

# Private DNS Zones (typically managed centrally)
resource "azurerm_private_dns_zone" "storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
  tags = {
    Purpose = "PrivateEndpoints"
    Service = "Storage"
  }
}

resource "azurerm_private_dns_zone" "storage_file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name
  tags = {
    Purpose = "PrivateEndpoints"
    Service = "Storage"
  }
}

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags = {
    Purpose = "PrivateEndpoints"
    Service = "KeyVault"
  }
}

# DNS Zone Virtual Network Links
resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob" {
  name                  = "storage-blob-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_file" {
  name                  = "storage-file-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_file.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "keyvault-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
}

# ==============================================================================
# OUTPUTS
# ==============================================================================

output "private_endpoints" {
  description = "Private endpoint details"
  value = {
    team_data_storage = {
      id         = module.team_data_storage_pe.private_endpoint_id
      private_ip = module.team_data_storage_pe.private_ip_address
    }
    shared_keyvault = {
      id         = module.shared_keyvault_pe.private_endpoint_id
      private_ip = module.shared_keyvault_pe.private_ip_address
    }
    app_storage_blob = {
      id         = module.app_storage_blob_pe.private_endpoint_id
      private_ip = module.app_storage_blob_pe.private_ip_address
    }
    app_storage_file = {
      id         = module.app_storage_file_pe.private_endpoint_id
      private_ip = module.app_storage_file_pe.private_ip_address
    }
  }
}
