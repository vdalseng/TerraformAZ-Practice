# 🌐 VNet Module Demo

This is a complete example of how to use the modernized Azure VNet Terraform module. It demonstrates the **minimal input strategy** with automatic CIDR calculation and secure defaults.

## 🚀 Quick Start

1. **Clone and navigate:**
   ```bash
   git clone <repository>
   cd revisioned-virtualnetwork-module
   ```

2. **Customize (optional):**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## 📊 What Gets Created

With the default configuration (`10.133.100.0/23`), this creates:

| Resource | Name | CIDR | Purpose |
|----------|------|------|---------|
| 🌐 VNet | `demo-dev-vnet` | `10.133.100.0/23` | Main network |
| 🖥️ Frontend Subnet | `frontend` | `10.133.100.0/25` | Web tier (128 IPs) |
| ⚙️ Backend Subnet | `backend` | `10.133.100.128/25` | App tier (128 IPs) |
| 💾 Data Subnet | `data` | `10.133.101.0/25` | Database tier (128 IPs) |
| 🔌 Endpoints Subnet | `endpoints` | `10.133.101.128/25` | Private endpoints (128 IPs) |
| 🛡️ NSG | `nsg-demo-dev` | N/A | Security rules for app subnets |

## 🔒 Security Features

- **Network Security Groups** attached to application subnets (not endpoints)
- **Three-tier architecture** with proper traffic flow rules:
  - Internet → Frontend (ports 80, 443)
  - Frontend → Backend (ports 8080, 8443)
  - Backend → Data (ports 1433, 5432, 3306)
- **Private endpoint subnet** isolated from application traffic
- **Minimal access principle** - only required connections allowed

## 🎯 Customization Options

### Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `system_name` | `demo` | System identifier for resource naming |
| `environment` | `dev` | Environment (dev/test/staging/prod) |
| `location` | `West Europe` | Azure region |
| `vnet_address_space` | `10.133.100.0/23` | VNet CIDR block |

### Advanced Features (Commented Examples)

The `main.tf` includes commented examples for:
- **🔌 Private Endpoints** for Azure services
- **🌐 VNet Peering** with DNS forwarding
- **🛡️ DDoS Protection** configuration

## 📈 Extending the Configuration

### Adding Private Endpoints

**Use official Microsoft-documented subresource names** - the module handles conflicts automatically:

```hcl
private_endpoint_configs = {
  storage_blob = {
    subnet_name       = "endpoints"
    resource_id       = azurerm_storage_account.example.id
    subresource_names = ["blob"]                    # ✅ Official Microsoft name
  }
  key_vault = {
    subnet_name       = "endpoints" 
    resource_id       = azurerm_key_vault.example.id
    subresource_names = ["vault"]                   # ✅ Official Microsoft name
  }
  cognitive_services = {
    subnet_name       = "endpoints"
    resource_id       = azurerm_cognitive_account.example.id
    subresource_names = ["account"]                 # ✅ Auto-resolves to cognitiveservices DNS
  }
  purview = {
    subnet_name       = "endpoints"
    resource_id       = azurerm_purview_account.example.id
    subresource_names = ["account"]                 # ✅ Auto-resolves to purview DNS
  }
}
```

🧠 **Smart Conflict Resolution**: For subresource names used by multiple services (like "account"), the module automatically examines the `resource_id` to determine the correct DNS zone. No extra configuration needed!

For the complete list of supported subresource names, see: `modules/terraform-azurerm-virtualnetwork/azure_private_link_zones.tf`

### Adding VNet Peering

Uncomment and modify the `vnet_peering_configs` section:

```hcl
vnet_peering_configs = {
  to_hub_vnet = {
    remote_vnet_name = "hub-vnet"
    remote_rg_name   = "rg-hub-prod"
    bidirectional    = false
    
    dns_forwarding = {
      enabled                 = true
      import_remote_dns_zones = true
      export_local_dns_zones  = false
    }
  }
}
```

## 🔍 Outputs

After deployment, you'll see:
- **VNet ID** for resource references
- **Subnet details** for compute deployments
- **Calculated CIDRs** for network planning
- **Private endpoint IPs** (if configured)
- **DNS zone names** (if configured)

## 🏗️ Architecture Benefits

- **🎯 Minimal Input**: Just specify address space, get full network
- **📊 Automatic CIDR**: No manual subnet calculations
- **🔒 Secure by Default**: NSG rules follow best practices  
- **🌐 Future-Ready**: Easy to add peering and private endpoints
- **👥 Team Autonomy**: Unidirectional peering preserves team boundaries

## 📚 Module Documentation

For complete module documentation, see: `./modules/terraform-azurerm-virtualnetwork/README.md`
