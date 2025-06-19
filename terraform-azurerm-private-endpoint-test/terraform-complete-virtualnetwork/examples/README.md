# VNet Module Examples

This directory contains clean, copy-paste ready examples demonstrating how to use the VNet module. Each example contains only the essential code: resource group creation, module usage, and string-based configuration values.

## Examples Overview

| File | Purpose | Features |
|------|---------|----------|
| `01-basic-vnet-with-subnets.tf` | Basic VNet example | VNet with two subnets |
| `02-pe-simple.tf` | Private endpoints | VNet with storage account private endpoint |
| `03-peering-simple.tf` | VNet peering | Hub-spoke VNet peering setup |
| `04-complete-example.tf` | All features | Comprehensive example with all module features |

## 🚀 How to Use These Examples

1. **Copy the example file** that matches your needs
2. **Update the string values** to match your requirements:
   - Resource group name and location
   - VNet name, system name, environment
   - IP address ranges (CIDR blocks)
   - Resource names

3. **Run Terraform**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## 📝 Example Structure

Each example follows this stripped down pattern:

```hcl
# Terraform provider configuration
terraform { ... }
provider "azurerm" { ... }

# Resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-your-name-here"
  location = "East US"
}

# Module usage with string-based values
module "your_network" {
  source = "../modules/terraform-azurerm-virtualnetwork"
  
  vnet_canonical_name = "your-vnet-name"
  system_name         = "your-system"
  environment         = "dev"
  resource_group      = azurerm_resource_group.example
  address_space       = ["10.0.0.0/16"]
  
  subnet_configs = {
    "subnet1" = "10.0.1.0/24"
    "subnet2" = "10.0.2.0/24"
  }
}
```

## Built-in Module Outputs

The module provides comprehensive outputs so you typically **don't need to define your own outputs**:

### 🎯 Most Commonly Used Outputs

```hcl
# VNet Information
module.your_network.vnet_id              # VNet resource ID
module.your_network.vnet_name            # VNet name
module.your_network.vnet_address_space   # ["10.0.0.0/16"]

# Subnet Information  
module.your_network.subnet_ids           # { "web" = "subnet-id-1", "api" = "subnet-id-2" }
module.your_network.subnet_cidrs         # { "web" = "10.0.1.0/24", "api" = "10.0.2.0/24" }

# Private Endpoint Information (if configured)
module.your_network.private_endpoint_ips # { "storage" = "10.0.4.5" }

# Complete Network Summary
module.your_network.network_summary      # Full network overview object
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

## 🔧 Customizing Examples

### Required Values to Update
When copying an example, update these string values:

```hcl
# Resource Group
name     = "rg-your-project-name"    # ← Change this
location = "East US"                 # ← Change to your region

# Module Configuration  
vnet_canonical_name = "your-app-name"   # ← Change this
system_name         = "your-system"     # ← Change this
environment         = "dev"             # ← Change this (dev/staging/prod)
address_space       = ["10.0.0.0/16"]   # ← Change IP range if needed

# Subnets
subnet_configs = {
  "your-subnet1" = "10.0.1.0/24"        # ← Change names and CIDRs
  "your-subnet2" = "10.0.2.0/24"        # ← Change names and CIDRs
}
```

### IP Address Planning
- Use private IP ranges from the Elvia reserved ranges: [elvia.atlassian.net/IP-rangene for Azure](https://elvia.atlassian.net/wiki/spaces/DOCHYBNET/pages/396165682/IP-rangene+for+Azure+Subscriptions)
- Ensure VNet CIDR is large enough for all subnets
- Avoid overlapping with existing networks
- Common patterns:
  - Dev: `10.133.1.x/24`
  - Staging: `10.133.2.x/24` 
  - Prod: `10.133.3.x/24`
  
  or

  - Dev: `10.133.1.0/26`
  - Test: `10.133.1.64/26`
  - Prod: `10.133.1.128/26`

  First option gives 256 IP-addresses to each vnet. You can still divide the subnets address ranges inside this vnet range.
  Last option gives 64 IP-adresses for each vnet and still allows for dividing up vnets and subnets over the same address range.

## 📚 Full Output Reference

| Output | Type | Description |
|--------|------|-------------|
| `vnet_id` | String | VNet resource ID |
| `vnet_name` | String | VNet name |
| `vnet_address_space` | List | VNet address spaces |
| `subnet_ids` | Map | Subnet name → ID mapping |
| `subnet_cidrs` | Map | Subnet name → CIDR mapping |
| `private_endpoint_ips` | Map | PE name → IP address mapping |
| `network_summary` | Object | Complete network summary |
| `azurerm_vnet` | Object | Full VNet resource |
| `azurerm_subnet` | Map | Map of all subnet resources |
| `azurerm_private_endpoint` | Map | Map of all private endpoint resources |
| `azurerm_vnet_peering` | Object | VNet peering resource (if created) |
