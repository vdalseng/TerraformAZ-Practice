# VNet Module Examples

> **🎯 Updated for Enhanced Module Capabilities**  
> All examples have been updated to leverage the enhanced VNet module with automatic DNS zone creation, multi-VNet peering with bidirectional support, automatic DNS forwarding between peered VNets, and Elvia IP address standards.

This directory contains comprehensive examples demonstrating the enhanced VNet module capabilities including automatic DNS zone creation, multi-VNet peering with bidirectional support, and automatic DNS forwarding between peered VNets.

## Examples Overview

### 🎯 Getting Started
1. **Start with basic VNet example** and add features incrementally
2. **Use Elvia IP ranges** from [Elvia IP documentation](https://elvia.atlassian.net/wiki/spaces/DOCHYBNET/pages/396165682/IP-rangene+for+Azure+Subscriptions)
3. **Follow naming conventions**: `{system}-{environment}` pattern
4. **Leverage automatic features**: DNS zones, peering, forwarding

### 🏗️ Architecture Patterns
- **Hub-Spoke**: Use bidirectional peering with DNS forwarding
- **Multi-Region**: Separate VNets per region, interconnect as needed
- **Service Isolation**: One VNet per major service/application
- **Shared Services**: Central hub for common resources

## Examples Overview

| File | Purpose | Features |
|------|---------|----------|
| `01-vnet-with-subnets-template.tf` | Basic VNet | Simple VNet with subnets |
| `02-pe-template.tf` | Private Endpoints | Multiple private endpoints with automatic DNS |
| `03-peering-template.tf` | Peer-to-Peer VNets | Two equal VNets with bidirectional peering & DNS forwarding |
| `04-complete-example.tf` | Multi-App Architecture | Three completely separate applications sharing resources via peering |
| `05-dns-forwarding-chain.tf` | DNS Forwarding Chain | VNet chain with transitive DNS resolution |

## 🚀 How to Use These Examples

1. **Choose the right example** for your use case:
   - **Basic VNet**: Start here for simple networking
   - **Private Endpoints**: For services requiring private connectivity  
   - **Peer-to-Peer VNets**: For two equal applications that need to share resources
   - **Multi-App Architecture**: For multiple completely separate applications sharing resources
   - **DNS Forwarding Chain**: For chained VNet connectivity patterns

2. **Copy the example file** and customize the values:
   - Resource group names and locations
   - VNet names, system names, environments
   - IP address ranges (use Elvia reserved ranges)
   - Resource-specific configurations

3. **Run Terraform**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## 🌟 Enhanced Module Features

### Automatic DNS Zone Management
- **Auto-creation**: DNS zones automatically created for private endpoints
- **Auto-discovery**: Module detects required zones from subresource types
- **Auto-linking**: DNS zones automatically linked to VNets

### Enhanced VNet Peering  
- **Multi-VNet support**: Connect to multiple VNets simultaneously
- **Bidirectional peering**: Automatic creation of both peering directions
- **DNS forwarding**: Automatic cross-VNet DNS zone sharing
- **RBAC-compliant**: Proper security boundaries maintained

### Cross-VNet DNS Resolution
- **Automatic forwarding**: Private endpoints resolvable across peered VNets
- **Transitive access**: VNet chains enable indirect connectivity
- **Zero configuration**: No manual DNS zone management required

## 📝 Example Structure

### Basic Pattern
Each example follows this foundation pattern:

```hcl
# Terraform and provider setup
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

# Resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-your-name-here"
  location = "norwayeast"
}

# Basic module usage
module "your_network" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "your-vnet-name"
  system_name         = "your-system"
  environment         = "dev"
  resource_group      = azurerm_resource_group.example
  address_space       = [cidrsubnet("10.0.0.0/16", 8, 1)]  # 10.0.1.0/24
  
  subnet_configs = {
    "subnet1" = cidrsubnet("10.0.0.0/16", 10, 4)   # 10.0.1.0/26
    "subnet2" = cidrsubnet("10.0.0.0/16", 10, 5)   # 10.0.1.64/26
  }
}
```

### Enhanced Peering Pattern
For multi-VNet scenarios with DNS forwarding:

```hcl
module "spoke_vnet" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  # ...basic configuration...
  
  # Enhanced peering with DNS forwarding
  vnet_peering_configs = {
    "to-hub" = {
      remote_vnet_name = "hub-vnet-name"
      remote_rg_name   = "rg-hub"
      bidirectional    = true
      
      dns_forwarding = {
        enabled             = true
        import_remote_zones = true  # Access hub resources
        export_local_zones  = true  # Share spoke resources
      }
    }
  }
}
```

### Private Endpoints Pattern
Automatic DNS zone creation and management:

```hcl
module "vnet_with_pe" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  # ...basic configuration...
  
  private_endpoint_configs = {
    "storage-blob" = {
      subnet_name       = "private-endpoints"
      resource_id       = azurerm_storage_account.example.id
      subresource_names = ["blob"]
      # DNS zones created automatically
    }
  }
}
```

## Built-in Module Outputs

The enhanced module provides comprehensive outputs for all networking components:

### 🎯 Essential Outputs

```hcl
# VNet Information
module.your_network.vnet_id              # VNet resource ID
module.your_network.vnet_name            # VNet name
module.your_network.vnet_address_space   # ["10.133.1.0/24"]

# Subnet Information  
module.your_network.subnet_ids           # { "web" = "subnet-id-1", "api" = "subnet-id-2" }
module.your_network.subnet_cidrs         # { "web" = "10.133.1.0/26", "api" = "10.133.1.64/26" }

# Private Endpoint Information
module.your_network.private_endpoint_ips # { "storage-blob" = "10.133.1.5" }
module.your_network.private_dns_zone_names # ["privatelink.blob.core.windows.net"]

# Enhanced Networking
module.your_network.network_summary      # Complete network overview with peering info
```

### 🔗 New Enhanced Outputs

```hcl
# Peering Information  
module.your_network.network_summary.peering.connections      # List of all peering connections
module.your_network.network_summary.peering.dns_forwarding   # DNS forwarding status

# DNS Forwarding Details
module.your_network.network_summary.dns.local_zones          # Zones created in this VNet  
module.your_network.network_summary.dns.forwarded_zones      # Zones forwarded from peers
module.your_network.network_summary.dns.exported_zones       # Zones exported to peers

# Cross-VNet Connectivity
module.your_network.network_summary.connectivity             # Which VNets can access what
```

### 🔗 Using Outputs in Other Resources

```hcl
# Reference subnet ID directly
resource "azurerm_network_interface" "example" {
  ip_configuration {
    subnet_id = module.your_network.subnet_ids["web"]
  }
}

# Reference VNet for peering
resource "azurerm_virtual_network_peering" "example" {
  virtual_network_name      = module.your_network.vnet_name
  remote_virtual_network_id = module.other_vnet.vnet_id
}
```

## � Best Practices

1. **Start with the minimal example** and add features as needed
2. **Use string values** for easy customization - no variables or complex expressions
3. **Copy and modify** - these examples are designed to be copied and customized
4. **Use built-in outputs** - the module provides all commonly needed outputs
5. **Keep it simple** - follow the clean pattern shown in these examples

## 🔧 Customization Guide

### Essential Values to Update
When copying an example, always update these values:

```hcl
# Resource Group
name     = "rg-your-project-name"          # ← Change this
location = "norwayeast"                    # ← Use Elvia regions

# Module Configuration  
vnet_canonical_name = "your-app-name"      # ← Application/system name
system_name         = "your-system"        # ← System identifier  
environment         = "dev"                # ← Environment (dev/test/prod)
address_space       = [cidrsubnet("10.0.0.0/16", 8, 1)]  # ← Dynamic IP allocation

# Subnets (using cidrsubnet for dynamic allocation)
subnet_configs = {
  "your-subnet1" = cidrsubnet("10.0.0.0/16", 10, 4)   # ← 64 IPs
  "your-subnet2" = cidrsubnet("10.0.0.0/16", 10, 5)   # ← 64 IPs
}
```

### Advanced Configuration

#### Enhanced Peering
```hcl
vnet_peering_configs = {
  "connection-name" = {
    remote_vnet_name = "target-vnet-name"
    remote_rg_name   = "target-resource-group"
    bidirectional    = true              # Creates both directions
    
    dns_forwarding = {
      enabled             = true
      import_remote_zones = true         # Access remote resources
      export_local_zones  = true         # Share local resources
    }
  }
}
```

#### Private Endpoints with Custom DNS
```hcl
private_endpoint_configs = {
  "unique-pe-name" = {
    subnet_name       = "private-endpoints"
    resource_id       = azurerm_storage_account.example.id
    subresource_names = ["blob", "file"]   # Multiple subresources
    # private_dns_zone_group = null        # Let module auto-create zones
  }
}
```

### 🌐 IP Address Planning

Use dynamic `cidrsubnet()` function for flexible IP allocation from a base range:

#### Dynamic IP Allocation Pattern

**Base Range: `10.0.0.0/16`** - Provides 65,536 IPs across 256 /24 networks

```hcl
# VNet Address Space (256 IPs each)
address_space = [cidrsubnet("10.0.0.0/16", 8, 1)]   # 10.0.1.0/24
address_space = [cidrsubnet("10.0.0.0/16", 8, 2)]   # 10.0.2.0/24
address_space = [cidrsubnet("10.0.0.0/16", 8, 3)]   # 10.0.3.0/24

# Subnet CIDR Blocks (64 IPs each)
subnet_configs = {
  "frontend" = cidrsubnet("10.0.0.0/16", 10, 4)    # 10.0.1.0/26
  "backend"  = cidrsubnet("10.0.0.0/16", 10, 5)    # 10.0.1.64/26
}
```

#### Example Allocation Scheme

**Environment Separation:**
```hcl
# Development - 10.0.1.0/24
address_space = [cidrsubnet("10.0.0.0/16", 8, 1)]

# Testing - 10.0.2.0/24  
address_space = [cidrsubnet("10.0.0.0/16", 8, 2)]

# Production - 10.0.10.0/24
address_space = [cidrsubnet("10.0.0.0/16", 8, 10)]
```

**Application Separation:**
```hcl
# App1 - 10.0.21.0/24
address_space = [cidrsubnet("10.0.0.0/16", 8, 21)]

# App2 - 10.0.22.0/24
address_space = [cidrsubnet("10.0.0.0/16", 8, 22)]

# Shared Services - 10.0.20.0/24
address_space = [cidrsubnet("10.0.0.0/16", 8, 20)]
```

#### Subnet Planning with cidrsubnet()

```hcl
# For any /24 VNet, create /26 subnets (64 IPs each)
subnet_configs = {
  "web"    = cidrsubnet("10.0.0.0/16", 10, subnet_index + 0)  # First /26
  "app"    = cidrsubnet("10.0.0.0/16", 10, subnet_index + 1)  # Second /26
  "data"   = cidrsubnet("10.0.0.0/16", 10, subnet_index + 2)  # Third /26
  "pe"     = cidrsubnet("10.0.0.0/16", 10, subnet_index + 3)  # Fourth /26
}
```

### 🚨 Important Notes
- **No Overlapping**: Ensure VNet CIDRs don't overlap across regions/environments
- **Future Growth**: Leave room for additional subnets
- **Private Endpoints**: Always include dedicated subnet for private endpoints
- **Azure Reserved**: Azure reserves first 4 and last 1 IP in each subnet

## 📚 Complete Output Reference

### Core Outputs
| Output | Type | Description |
|--------|------|-------------|
| `vnet_id` | String | VNet resource ID |
| `vnet_name` | String | VNet name |
| `vnet_address_space` | List | VNet address spaces |
| `subnet_ids` | Map | Subnet name → ID mapping |
| `subnet_cidrs` | Map | Subnet name → CIDR mapping |

### Enhanced Networking Outputs  
| Output | Type | Description |
|--------|------|-------------|
| `private_endpoint_ips` | Map | PE name → IP address mapping |
| `private_dns_zone_names` | List | DNS zones created by this module |
| `private_dns_zone_ids` | Map | Zone name → resource ID mapping |

### Multi-VNet Outputs
| Output | Type | Description |
|--------|------|-------------|
| `network_summary` | Object | Complete network summary with peering |
| `network_summary.peering` | Object | All peering connection details |
| `network_summary.dns` | Object | DNS forwarding configuration |
| `network_summary.connectivity` | Object | Cross-VNet access capabilities |

### Resource Access Outputs
| Output | Type | Description |
|--------|------|-------------|
| `azurerm_vnet` | Object | Full VNet resource |
| `azurerm_subnet` | Map | Map of all subnet resources |
| `azurerm_private_endpoint` | Map | Map of all private endpoint resources |
| `azurerm_vnet_peering` | Map | Map of all peering resources |
