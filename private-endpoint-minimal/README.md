# Minimal Private Endpoint Module

A simple, reusable Terraform module for creating Azure private endpoints with optional DNS integration.

## Purpose

This module creates private endpoints for Azure PaaS services with minimal complexity. It's designed for:
- Multi-team organizational use
- Consistent private endpoint deployment
- Secure access to Azure services without public internet exposure
- Simple DNS integration when needed

## Features

✅ **Simple** - Only essential parameters, no complex configurations  
✅ **Reusable** - Works with any Azure service that supports private endpoints  
✅ **Secure** - Enforces private-only access patterns  
✅ **Flexible** - Optional DNS integration  

## Usage

```hcl
module "storage_private_endpoint" {
  source = "./modules/private-endpoint-minimal"

  name                = "mystorageaccount-pe"
  location            = "East US"
  resource_group_name = "my-rg"
  subnet_id           = "/subscriptions/.../subnets/private-endpoints"
  target_resource_id  = azurerm_storage_account.example.id
  subresource_names   = ["blob"]
  private_dns_zone_id = azurerm_private_dns_zone.blob.id

  tags = {
    Environment = "Production"
    Team        = "Data"
  }
}
```

## Common Service Configurations

### Storage Account - Blob
```hcl
subresource_names   = ["blob"]
# DNS zone: privatelink.blob.core.windows.net
```

### Storage Account - File
```hcl
subresource_names   = ["file"]
# DNS zone: privatelink.file.core.windows.net
```

### Key Vault
```hcl
subresource_names   = ["vault"]
# DNS zone: privatelink.vaultcore.azure.net
```

### SQL Database
```hcl
subresource_names   = ["sqlServer"]
# DNS zone: privatelink.database.windows.net
```

### App Service
```hcl
subresource_names   = ["sites"]
# DNS zone: privatelink.azurewebsites.net
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the private endpoint | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| subnet_id | Subnet ID for private endpoint | `string` | n/a | yes |
| target_resource_id | Resource ID of the target Azure service | `string` | n/a | yes |
| subresource_names | Subresource names for the private endpoint | `list(string)` | n/a | yes |
| private_dns_zone_id | Private DNS zone ID (optional) | `string` | `null` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| private_endpoint_id | ID of the private endpoint |
| private_endpoint_name | Name of the private endpoint |
| private_ip_address | Private IP address of the private endpoint |
| network_interface_id | Network interface ID of the private endpoint |

## Prerequisites

Before using this module, ensure:

1. **Subnet Configuration**: The target subnet must have `private_endpoint_network_policies_enabled = false`
   ```hcl
   resource "azurerm_subnet" "private_endpoints" {
     # ... other configuration ...
     private_endpoint_network_policies_enabled = false
   }
   ```

2. **DNS Zone**: If using DNS integration, create the appropriate private DNS zone:
   ```hcl
   resource "azurerm_private_dns_zone" "blob" {
     name                = "privatelink.blob.core.windows.net"
     resource_group_name = azurerm_resource_group.example.name
   }
   ```

3. **VNet Link**: Link the DNS zone to your virtual network:
   ```hcl
   resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
     name                  = "blob-dns-link"
     resource_group_name   = azurerm_resource_group.example.name
     private_dns_zone_name = azurerm_private_dns_zone.blob.name
     virtual_network_id    = azurerm_virtual_network.example.id
   }
   ```

## Complete Example

```hcl
# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "private-endpoint-example"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet for Private Endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                                          = "private-endpoints"
  resource_group_name                          = azurerm_resource_group.example.name
  virtual_network_name                         = azurerm_virtual_network.example.name
  address_prefixes                             = ["10.0.1.0/24"]
  private_endpoint_network_policies_enabled    = false
}

# Storage Account
resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct123"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Disable public access
  public_network_access_enabled = false
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

# DNS Zone VNet Link
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "blob-dns-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

# Private Endpoint using the module
module "storage_blob_pe" {
  source = "./modules/private-endpoint-minimal"

  name                = "storage-blob-pe"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  target_resource_id  = azurerm_storage_account.example.id
  subresource_names   = ["blob"]
  private_dns_zone_id = azurerm_private_dns_zone.blob.id

  tags = {
    Environment = "Example"
    Purpose     = "PrivateAccess"
  }
}
```

## Best Practices

1. **Use dedicated subnets** for private endpoints
2. **Disable public access** on target resources when using private endpoints
3. **Implement proper NSG rules** to control traffic flow
4. **Use consistent naming** conventions across teams
5. **Tag resources** appropriately for management and billing
6. **Plan DNS zones** carefully for organizational use
7. **Test connectivity** from VMs in the same VNet to verify private access

## Security Considerations

- Private endpoints create network interfaces in your subnet with private IP addresses
- Traffic flows privately within Azure backbone, never over public internet
- DNS resolution must be configured properly for applications to resolve private endpoints
- Consider network security groups (NSGs) and user-defined routes (UDRs) for additional security layers

## Troubleshooting

**Common Issues:**
1. **DNS Resolution**: Ensure private DNS zones are linked to VNets where clients reside
2. **Subnet Policies**: Verify `private_endpoint_network_policies_enabled = false` on target subnet
3. **Public Access**: Confirm target resource has public access disabled
4. **NSG Rules**: Check that NSG rules allow required traffic patterns

**Testing Connection:**
```bash
# From a VM in the same VNet, test DNS resolution
nslookup mystorageaccount.blob.core.windows.net

# Should return private IP (10.x.x.x), not public IP
```
