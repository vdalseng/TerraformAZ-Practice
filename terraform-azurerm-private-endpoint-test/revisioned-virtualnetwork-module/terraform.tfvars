# 🌐 Central Configuration for VNet Module Demo
# This file contains all the configuration values that will be used consistently across resources

# 🏷️ Basic identification
system_name = "demo"
environment = "dev"

# 🌍 Azure region - used consistently for all resources
location = "Norway East"

# 🌐 Network configuration
vnet_address_space = "10.133.100.0/23"

# 🛡️ Security configuration
enable_ddos_protection = false
# ddos_protection_plan_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/ddosProtectionPlans/xxx"

# 🏷️ Additional tags applied to all resources
additional_tags = {
  CostCenter  = "IT-Infrastructure"
  Owner       = "platform-team"
  Project     = "network-modernization"
  Environment = "dev"  # Reinforces the environment variable
}
