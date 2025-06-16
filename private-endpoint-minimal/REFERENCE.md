# Quick Reference: Azure Private Endpoint Subresources

This guide provides the `subresource_names` and DNS zone names for common Azure services.

## Storage Account
| Service | Subresource | DNS Zone |
|---------|-------------|----------|
| Blob Storage | `["blob"]` | `privatelink.blob.core.windows.net` |
| File Storage | `["file"]` | `privatelink.file.core.windows.net` |
| Table Storage | `["table"]` | `privatelink.table.core.windows.net` |
| Queue Storage | `["queue"]` | `privatelink.queue.core.windows.net` |
| Data Lake Gen2 | `["dfs"]` | `privatelink.dfs.core.windows.net` |

## Database Services
| Service | Subresource | DNS Zone |
|---------|-------------|----------|
| Azure SQL Database | `["sqlServer"]` | `privatelink.database.windows.net` |
| MySQL | `["mysqlServer"]` | `privatelink.mysql.database.azure.com` |
| PostgreSQL | `["postgresqlServer"]` | `privatelink.postgres.database.azure.com` |
| Cosmos DB (SQL) | `["Sql"]` | `privatelink.documents.azure.com` |
| Cosmos DB (MongoDB) | `["MongoDB"]` | `privatelink.mongo.cosmos.azure.com` |
| Cosmos DB (Cassandra) | `["Cassandra"]` | `privatelink.cassandra.cosmos.azure.com` |

## Security & Management
| Service | Subresource | DNS Zone |
|---------|-------------|----------|
| Key Vault | `["vault"]` | `privatelink.vaultcore.azure.net` |
| App Configuration | `["configurationStores"]` | `privatelink.azconfig.io` |

## Compute & Web
| Service | Subresource | DNS Zone |
|---------|-------------|----------|
| App Service | `["sites"]` | `privatelink.azurewebsites.net` |
| Function Apps | `["sites"]` | `privatelink.azurewebsites.net` |
| Container Registry | `["registry"]` | `privatelink.azurecr.io` |
| Kubernetes Service | `["management"]` | `privatelink.<region>.azmk8s.io` |

## AI & Analytics
| Service | Subresource | DNS Zone |
|---------|-------------|----------|
| Cognitive Services | `["account"]` | `privatelink.cognitiveservices.azure.com` |
| Search Service | `["searchService"]` | `privatelink.search.windows.net` |
| Event Hubs | `["namespace"]` | `privatelink.servicebus.windows.net` |
| Service Bus | `["namespace"]` | `privatelink.servicebus.windows.net` |

## Monitoring & DevOps
| Service | Subresource | DNS Zone |
|---------|-------------|----------|
| Log Analytics | `["azuremonitor"]` | `privatelink.monitor.azure.com` |
| Application Insights | `["azuremonitor"]` | `privatelink.monitor.azure.com` |

## Example Usage Templates

### Storage Account Blob
```hcl
module "storage_blob_pe" {
  source = "./modules/private-endpoint-minimal"
  
  name                = "mystorageaccount-blob-pe"
  location            = "East US"
  resource_group_name = "my-rg"
  subnet_id           = azurerm_subnet.private_endpoints.id
  target_resource_id  = azurerm_storage_account.example.id
  subresource_names   = ["blob"]
  private_dns_zone_id = azurerm_private_dns_zone.blob.id
}
```

### Key Vault
```hcl
module "keyvault_pe" {
  source = "./modules/private-endpoint-minimal"
  
  name                = "mykeyvault-pe"
  location            = "East US"
  resource_group_name = "my-rg"
  subnet_id           = azurerm_subnet.private_endpoints.id
  target_resource_id  = azurerm_key_vault.example.id
  subresource_names   = ["vault"]
  private_dns_zone_id = azurerm_private_dns_zone.keyvault.id
}
```

### SQL Database
```hcl
module "sql_pe" {
  source = "./modules/private-endpoint-minimal"
  
  name                = "mysqlserver-pe"
  location            = "East US"
  resource_group_name = "my-rg"
  subnet_id           = azurerm_subnet.private_endpoints.id
  target_resource_id  = azurerm_mssql_server.example.id
  subresource_names   = ["sqlServer"]
  private_dns_zone_id = azurerm_private_dns_zone.sql.id
}
```

## DNS Zone Creation Templates

```hcl
# Storage Blob
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

# Key Vault
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

# SQL Database
resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
}
```

## Subnet Requirements

```hcl
resource "azurerm_subnet" "private_endpoints" {
  name                                          = "private-endpoints"
  resource_group_name                          = azurerm_resource_group.example.name
  virtual_network_name                         = azurerm_virtual_network.example.name
  address_prefixes                             = ["10.0.10.0/24"]
  private_endpoint_network_policies_enabled    = false  # Required!
}
```

## Common Patterns

### Multi-Service Storage Account
```hcl
# Blob endpoint
module "storage_blob_pe" {
  source              = "./modules/private-endpoint-minimal"
  name                = "storage-blob-pe"
  # ... other params ...
  subresource_names   = ["blob"]
  private_dns_zone_id = azurerm_private_dns_zone.blob.id
}

# File endpoint  
module "storage_file_pe" {
  source              = "./modules/private-endpoint-minimal"
  name                = "storage-file-pe"
  # ... other params ...
  subresource_names   = ["file"]
  private_dns_zone_id = azurerm_private_dns_zone.file.id
}
```

### Team-Based Naming
```hcl
module "team_data_storage_pe" {
  source = "./modules/private-endpoint-minimal"
  name   = "${var.team_name}-${var.service_name}-pe"
  
  tags = {
    Team        = var.team_name
    Environment = var.environment
    Service     = var.service_name
  }
}
```
