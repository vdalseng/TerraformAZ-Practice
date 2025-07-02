# Test outputs for verifying module functionality
output "vnet1_output" {
  description = "Output from VNet 1 module"
  value       = module.vnet1.network_summary
}

output "vnet2_output" {
  description = "Output from VNet 2 module"
  value       = module.vnet2.network_summary
}

# Specific outputs for testing peering information
output "vnet1_peering_info" {
  description = "VNet 1 peering information"
  value       = module.vnet1.network_summary.peering
}

output "vnet2_peering_info" {
  description = "VNet 2 peering information"
  value       = module.vnet2.network_summary.peering
}

# Outputs for verifying that remote VNet names and resource groups are passed correctly
output "vnet1_peering_connections" {
  description = "VNet 1 peering connection details (remote VNet names and RG names)"
  value = {
    for key, connection in module.vnet1.network_summary.peering.connections : key => {
      remote_vnet = connection.remote_vnet
      remote_rg   = connection.remote_rg
    }
  }
}

output "vnet2_peering_connections" {
  description = "VNet 2 peering connection details (remote VNet names and RG names)"
  value = {
    for key, connection in module.vnet2.network_summary.peering.connections : key => {
      remote_vnet = connection.remote_vnet
      remote_rg   = connection.remote_rg
    }
  }
}
