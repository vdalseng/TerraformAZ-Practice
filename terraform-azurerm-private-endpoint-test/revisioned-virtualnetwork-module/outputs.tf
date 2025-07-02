# 📤 Root Module Outputs - Complete resource details
# These outputs display all available information about the created resources

# 🌐 VNet - Complete details
output "vnet" {
  description = "Complete VNet resource details"
  value       = module.vnet.vnet
}

# 📦 Resource Group - Complete details  
output "resource_group" {
  description = "Complete resource group details"
  value       = azurerm_resource_group.example
}

# 📊 Subnets - All subnet details
output "subnets" {
  description = "All subnet resource details"
  value       = module.vnet.subnet
}

# 🔌 Private Endpoints - All details (only if any exist)
output "private_endpoints" {
  description = "Private endpoint IP addresses"
  value       = module.vnet.private_endpoint_ips
}

# 🌐 DNS Zones - All details (only if any exist)
output "dns_zones" {
  description = "Private DNS zone names"
  value       = module.vnet.private_dns_zone_names
}
