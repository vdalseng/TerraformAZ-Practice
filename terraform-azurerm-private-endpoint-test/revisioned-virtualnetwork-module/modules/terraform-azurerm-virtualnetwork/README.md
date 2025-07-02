# Terraform Azurerm VirtualNetwork Module

## What this module contains

| Network Resources | Purpose | Optional | Default |
|:----------|:----------|:----------|:----------|
| 🌐 **Virtual Network** | Creates an isolated network which serves as the core foundation of your virtual network. | ❌ | Address space |
| 🔗🎛️ **Subnets** | Creates a subnet for you to attach network specific resources <br> like Private Endpoints, NSG's and so on. | ✅ | User defined |
| 🛡️ **NSG** | Creates a Network Security Group with inbound and outbound network traffic rules. <br> Allows the user to control network traffic. | ✅ | `{}` |
| 🔒 **Private Endpoints** | Creates a Private Endpoint which allows for secure Azure service access. | ✅ | `{}` |
| 📡 **Private DNS** | Creates a private DNS zone for each service group, housing `A records`, <br> which helps navigate traffic to the correct addresses. | ❌ | Automated setup <br> Requires Private Endpoint |
| ↔️ **Peering** | Creates a peering, which allows VNets communicate across Resource Groups and Regions. | ✅ | `{}` |
| **DNS Forwarding** | When you want to resolve communication with other VNets, allow them <br> to communicate with your VNet and use your DNS. | ✅ | `{}` |