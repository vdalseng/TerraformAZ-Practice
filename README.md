# Terraform Azure Practice Repository

This repository contains various Terraform configurations and modules for learning and practicing Azure infrastructure deployment. None are recommended for production use. They have been created to give me a better understanding of both Terraform as a IaC language and tool, as well as learning about Azure and its resources, as well as configuring Azure specific modules within the Virtual Networking space.

(Note: Nothing in this repo is finished and still needs cleanup and is only intended for practicing and learning Terraform and the Azure Platform)

## 📁 Folder Structure

### 📚 `learning-terraform-basics/`
**Educational foundation for Terraform and Azure**

A comprehensive learning repository designed for beginners to understand Terraform fundamentals with Azure. Contains examples for creating and managing basic Azure resources like Storage Accounts and Key Vaults. Includes step-by-step guides for authentication, setup, and resource management.

**Key Features:**
- Educational examples with detailed documentation
- Modular structure with separate components (key-vault, storage-account, virtual-machine, etc.)
- Complete setup instructions from Azure CLI installation to resource deployment
- Best practices for Terraform Azure development

---

### 🔒 `private-endpoint-minimal/`
**Minimal private endpoint module**

An attempt to create a small private endpoint module. At the time of creating this I did not have the full understanding of how to create modules so this was a way for me to experiment with creating a small module while researching Azure Networking.
Its a simple, somewhat reusable Terraform module for creating Azure private endpoints with optional DNS integration. Not for production use.

**Key Features:**
- Simple showcase of a single-purpose private endpoint module
- Optional DNS integration
- Secure access to Azure services without public internet exposure in a local vnet setting
- Minimal configuration required

---

### 🧪 `private-endpoint-test-module/`
**Testing environment for private endpoint development**

Another private endpoint module instance which builds upon my research and discoveries in the previously mentioned folder `private-endpoint-minimal/`.
Contains a more slightly better terraform project structure with a subfolder for modules. Includes the `terraform-azurerm-private-endpoint` submodule with examples and a visual diagram showing the thoughtprocess for building the private endpoint module and its intended use inside a vnet.

**Key Features:**
- Private endpoint module with testing setup
- Visual documentation with network diagrams
- Example configurations for storage accounts and other Azure services
- Development and testing focused

---

### 🌐 `terraform-azurerm-private-networking/`
**Advanced networking modules and configurations**

#### 🎯 `terraform-virtualnetwork-module/` *(Main Project)*
**Comprehensive VNet module with auto-discovery Private DNS**

The primary virtual network module featuring automatic Private DNS zone discovery and configuration. This is the most advanced and complete networking solution in the repository.

**Key Features:**
- **Auto-Discovery**: Automatically discovers and creates required Private DNS zones
- **Comprehensive Lookup**: Uses authoritative DNS mappings for Azure services
- **Private by Default**: Features like private endpoints and private DNS zones enable private connectivity within the vnet
- **Zero Configuration DNS**: Automatic private DNS zone setup by default, but manual configuration is optional
- **Resource Group Scoped**: Simplified management within single resource group

#### 📂 `old-vnet-module/`
Legacy VNet module with manual configurations and examples. Contains older approaches to virtual networking setup with peering examples and manual DNS configuration.

---

## 🚀 Getting Started

1. **Prerequisites:**
   - [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
   - [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
   - Azure subscription with appropriate permissions

2. **Quick Start:**
   ```bash
   # Clone the repository
   git clone <repository-url>
   cd TerraformAZ-Practice
   
   # Navigate to desired module
   cd terraform-azurerm-private-networking/terraform-virtualnetwork-module
   
   # Initialize Terraform
   terraform init
   
   # Plan your deployment
   terraform plan
   
   # Apply configuration
   terraform apply
   ```

3. **For learning and starting with terraform:** Start with `learning-terraform-basics/` for foundational knowledge
4. **For more indepth look at Azure networking:** Use `terraform-azurerm-private-networking/terraform-virtualnetwork-module/` for advanced networking

## 📖 Documentation

Each folder contains its own README with specific instructions, examples, and best practices. Refer to individual folder documentation for detailed usage instructions.

## 🎯 Repository Purpose

This repository serves as both a learning resource and a collection of production-ready Terraform modules for Azure infrastructure, with emphasis on secure networking and private connectivity patterns.
