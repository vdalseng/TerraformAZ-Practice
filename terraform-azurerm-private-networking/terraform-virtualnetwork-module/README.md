# 🌐 Azure VNet Module with Auto-Discovery Private DNS

A comprehensive, out-of-the-box Terraform module for creating Azure Virtual Networks with subnets, private endpoints, and automatically configured Private DNS zones.

## ✨ Features

- **🔄 Auto-Discovery**: Automatically discovers and creates required Private DNS zones based on private endpoint subresource types
- **📋 Comprehensive Lookup**: Uses `azure_private_link_zones.tf` as the authoritative source for Azure service DNS mappings
- **�️ Private by Default**: Creates private endpoints with automatic DNS resolution
- **🏗️ Flexible Architecture**: Supports both private networking and controlled public access at the resource level
- **🎯 Zero Configuration DNS**: No need to manually specify DNS zone names - they're discovered automatically
- **🔗 Resource Group Scoped**: All resources created within a single resource group for simplified management

## 🚀 Quick Start

### Basic Usage

```hcl
module "vnet_example" {
  source = "./modules/terraform-azurerm-virtualnetwork"

  vnet_canonical_name = "example-vnet"
  system_name         = "myapp"
  environment         = "dev"
  resource_group      = azurerm_resource_group.example

  address_space = ["10.0.0.0/23"]

  subnet_configs = {
    workloads = "10.0.0.0/24"
    endpoints = "10.0.1.0/24"
  }

  private_endpoint_configs = {
    storage_blob = {
      subnet_name       = "endpoints"
      resource_id       = azurerm_storage_account.example.id
      subresource_names = ["blob"]  # Auto-discovers privatelink.blob.core.windows.net
    }
  }
}
```

## 🎯 Example: Storage Account with Private Endpoint

The included `main.tf` demonstrates a complete example:

```hcl
# Creates a VNet with workloads and endpoints subnets
module "vnet_a" {
  source = "./modules/terraform-azurerm-virtualnetwork"

  vnet_canonical_name = "demo-net-a"
  system_name         = "demo"
  environment         = "dev"
  resource_group      = azurerm_resource_group.network

  address_space = ["10.133.100.0/23"]

  subnet_configs = {
    workloads = "10.133.100.0/24"   # 254 IPs for workloads
    endpoints = "10.133.101.0/24"   # 254 IPs for private endpoints
  }

  private_endpoint_configs = {
    storage_blob = {
      subnet_name       = "endpoints"
      resource_id       = azurerm_storage_account.example.id
      subresource_names = ["blob"]
      # DNS zone "privatelink.blob.core.windows.net" created automatically!
    }
  }
}
```

## 🔍 Auto-Discovery in Action

1. **Subresource Detection**: Module detects `["blob"]` in the private endpoint config
2. **DNS Lookup**: Searches `azure_private_link_zones.tf` for the blob service
3. **Zone Creation**: Automatically creates `privatelink.blob.core.windows.net`
4. **VNet Linking**: Links the VNet to the DNS zone
5. **Endpoint Integration**: Configures private endpoint to use the DNS zone

## � Getting Started

1. **Clone or copy** the module to your project
2. **Configure** your `terraform.tfvars`:
   ```hcl
   system_name = "myapp"
   environment = "dev"
   location = "Norway East"
   vnet_a_address_space = "10.0.0.0/23"
   ```
3. **Deploy** with standard Terraform commands:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

---

**Ready to deploy secure, private Azure networking with zero DNS configuration hassle? This module has you covered! 🚀**
