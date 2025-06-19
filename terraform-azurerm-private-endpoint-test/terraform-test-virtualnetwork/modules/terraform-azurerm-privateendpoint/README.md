# Azure Private Endpoint Terraform Module

This Terraform module creates an Azure Private Endpoint with support for multiple private service connections. It allows you to securely connect to Azure services over a private network instead of the public internet.

## Features

- ✅ Create a single private endpoint with multiple service connections
- ✅ Support for custom connection names or auto-generated names
- ✅ Connect to any Azure service that supports private endpoints
- ✅ Flexible configuration for different subresource types
- ✅ Comprehensive outputs for connection details and IP addresses

## Usage

### Basic Example

```terraform
module "private_endpoint" {
  source = "./modules/terraform-azurerm-privateendpoint"
  
  resource_group = {
    name     = "my-resource-group"
    location = "East US"
  }
  
  resource_name = "myapp"
  subnet_id     = "/subscriptions/.../subnets/private-subnet"
  
  private_connection_resources = {
    "storage-blob" = {
      resource_id       = azurerm_storage_account.example.id
      subresource_names = ["blob"]
    }
  }
}
```

### Advanced Example with Multiple Connections

```terraform
module "private_endpoint" {
  source = "./modules/terraform-azurerm-privateendpoint"
  
  resource_group = {
    name     = "my-resource-group"
    location = "East US"
  }
  
  resource_name = "myapp"
  subnet_id     = azurerm_subnet.private.id
  
  private_connection_resources = {
    "storage-blob" = {
      name              = "custom-blob-connection"  # Optional custom name
      resource_id       = azurerm_storage_account.primary.id
      subresource_names = ["blob"]
    }
    "storage-file" = {
      resource_id       = azurerm_storage_account.primary.id
      subresource_names = ["file"]
    }
    "keyvault" = {
      resource_id       = azurerm_key_vault.vault.id
      subresource_names = ["vault"]
    }
  }
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `resource_group` | The resource group information containing name and location | `object({ name = string, location = string })` | ✅ | - |
| `resource_name` | The base name used for naming the private endpoint | `string` | ✅ | - |
| `subnet_id` | The ID of the subnet where the private endpoint will be created | `string` | ✅ | - |
| `private_connection_resources` | Map of private connection configurations | `map(object({ name = optional(string), resource_id = string, subresource_names = optional(list(string)) }))` | ✅ | - |

### Input Details

#### `resource_group`
Object containing the resource group details:
- `name` - Name of the existing resource group
- `location` - Azure region where resources are located

#### `private_connection_resources`
Map where each key represents a connection identifier and the value contains:
- `name` (optional) - Custom name for the private service connection. If not provided, auto-generates as `${resource_name}-${key}-psc`
- `resource_id` - Full Azure resource ID of the service to connect to
- `subresource_names` (optional) - List of subresource types to connect to (e.g., `["blob"]`, `["vault"]`)

### Common Subresource Names

| Azure Service | Subresource Names | Example |
|---------------|-------------------|---------|
| Storage Account | `blob`, `file`, `queue`, `table`, `web`, `dfs` | `["blob"]` |
| Key Vault | `vault` | `["vault"]` |
| SQL Database | `sqlServer` | `["sqlServer"]` |
| Cosmos DB | `sql`, `mongodb`, `cassandra`, `gremlin`, `table` | `["sql"]` |
| Service Bus | `namespace` | `["namespace"]` |
| Container Registry | `registry` | `["registry"]` |

## Outputs

| Name | Description |
|------|-------------|
| private_endpoint_id | The ID of the private endpoint |
| private_service_connections | Map of private service connection details including names, resource IDs, subresource names, and private IP addresses |

### Output Usage Examples

```hcl
# Get the private endpoint ID
private_endpoint_id = module.private_endpoint.private_endpoint_id

# Get specific connection's private IP address
storage_private_ip = module.private_endpoint.private_service_connections["myapp-storage-connection-psc"].private_ip_address

# Get all connection details
all_connections = module.private_endpoint.private_service_connections
```

## Important Notes

### Automatic Network Interface Creation

When you create a private endpoint, **Azure automatically creates a Network Interface Card (NIC)** with the following characteristics:

- **Naming Convention**: `{private-endpoint-name}.nic`
- **Example**: If your private endpoint is named `myapp-pe`, Azure creates `myapp-pe.nic`
- **Purpose**: Routes traffic from your VNet to the target Azure service privately
- **IP Assignment**: Gets a private IP address from your specified subnet
- **Management**: This NIC is automatically managed by Azure - you don't need to define it in Terraform

### Private IP Address Allocation

- **Multiple Connections = Multiple IPs**: Each private service connection gets its own dedicated private IP address
- **Subnet Planning**: Ensure your subnet has sufficient IP addresses for all connections
- **DNS Resolution**: Each connection gets its own DNS entry pointing to its private IP

### Example IP Allocation

```
Private Endpoint: myapp-pe
├── Connection 1: myapp-storage-blob-psc    → 10.0.1.4
├── Connection 2: myapp-storage-file-psc    → 10.0.1.5
└── Connection 3: myapp-keyvault-psc        → 10.0.1.6

Automatically Created NIC: myapp-pe.nic (manages all above IPs)
```

### DNS Integration

For proper DNS resolution, consider configuring:
- Private DNS zones for your services
- DNS zone groups in your private endpoint
- Conditional DNS forwarding if needed

## Examples

### Accessing Output Values

```terraform
# Get the private endpoint ID
output "pe_id" {
  value = module.private_endpoint.private_endpoint_id
}

# Get specific connection's private IP
output "storage_private_ip" {
  value = module.private_endpoint.private_service_connections["myapp-storage-blob-psc"].private_ip_address
}

# Get all connection details
output "all_connections" {
  value = module.private_endpoint.private_service_connections
}
```

### Multiple Storage Account Connections

```terraform
module "private_endpoint" {
  source = "./modules/terraform-azurerm-privateendpoint"
  
  resource_group = azurerm_resource_group.example
  resource_name  = "webapp"
  subnet_id      = azurerm_subnet.private.id
  
  private_connection_resources = {
    for name in var.storage_account_names : "${name}-storage" => {
      resource_id       = azurerm_storage_account.storage[name].id
      subresource_names = ["blob"]
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Notes

- Each private service connection consumes one private IP address from the specified subnet
- Ensure your subnet has sufficient available IP addresses for all planned connections
- Private endpoints automatically handle DNS resolution when integrated with private DNS zones
- The module creates automatic (non-manual) connections by default

## License

This module is provided as-is for educational and development purposes.
