# 📚 Table of Contents
- [Repository Purpose](#repository-purpose)
- [Prerequisites](#prerequisites)
- [How to Set Up Repository Locally](#how-to-set-up-repository-locally)
- [Logging in to Azure](#logging-in-to-azure)
- [Running Terraform](#running-terraform)
- [Setting Up Your First Resource](#setting-up-your-first-resource)
- [Cleaning up resources](#cleaning-up-resources)


# 📚 Repository Purpose
This repository is designed as a learning tool for developing Terraform solutions in Azure. It provides examples of how to create and manage Azure resources, such as Storage Accounts and Key Vaults, using Terraform. Note: This repository is for educational purposes only and is not intended for production use.


# 🛠️ Prerequisites
Before using this repository, ensure you have the following:
- A Microsoft Azure account with an active subscription.
- Terraform installed on your local machine. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- Azure CLI installed and authenticated. [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

    - [Windows installer](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&pivots=msi-powershell)
    - [MacOS Installer](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest)
    - [Linux Installer](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?view=azure-cli-latest&pivots=apt)


# Setup

## 💻 How To Set Up Repository Locally
1. 📂 Clone this repository to your local machine:
   ```bash
   git clone https://github.com/your-repo-name.git
   cd your-repo-name
   ```

2. 🔑 Ensure you have a Microsoft Azure subscription enabled. If you don't have one, follow these steps:
    
    - ✔️ Go to **Microsoft Azure > Home > [Subscriptions](https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBladeV2)**
    
    ✔️ Create a new subscription or access an existing one.
    
    ✔️ Copy the Subscription ID.

3. 📝 Create a ``variables.tf`` file in the root of the repository and add the following code:

    ```hcl
    variable "subscription_id" {
        default = "<your-subscription-id>"
    }
    ```


## 🔑 Logging In To Azure
Before running Terraform commands, ensure you are authenticated with Azure using the Azure CLI. Follow these steps:

1. Open a terminal and log in to Azure:
   ```bash
   az login
   ```

2. This will prompt you to log in to your microsoft account. Once signed in, the terminal will display your active subscription. Your default subscription may be marked with ``*``. 

3. If you want to change your subscription you can do so right after login in by typing:
    ```bash
    az account set subscription "<your-subscription-id>"
    ```
    You can find your subscription ID by either going to **Microsoft Azure > Home > [Subscriptions](https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBladeV2)** or by typing:
    ```bash
    az account list
    ```


## 🚀 Running Terraform
1. Initialize Terraform:
    ```bash
    terraform init
    ```
2. Run to preview the resources that will be created, edited or destroyed.
    ```bash
    terraform plan
    ```
3. Apply the configuration to create, edit or destroy the resources:
    ```bash
    terraform apply
    ```


## 🌱 Setting Up Your First Resource
Now that you have everything set up, you can start creating resources. In the `main.tf` file, there are already some resources set up, including:
- 📦 A **Resource Group** to organize your resources.
- 🗄️ A **Storage Account** for storing data.
- 🔐 A **Key Vault** for securely storing secrets.
- 🔑 A **Key Vault Secret** to store the primary access key of the Storage Account.

These resources are connected and can serve as a reference point for experimenting and learning the basics of Terraform.

To learn more about setting up resources in Terraform, take a look at the [Terraform documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs).


## 🧹 Cleaning Up Resources
When you're done experimenting, you can destroy all the resources created by Terraform to avoid incurring costs:
```bash
terraform destroy
```


# 🔗 References
Here are some helpful resources to learn more about Terraform and Azure:

- [Terraform Registry - AzureRM Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Official Documentation](https://developer.hashicorp.com/terraform/docs)
- [Azure Getting Started Guide](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview)
- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [Azure Subscription Management](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/create-subscription)
- [Terraform Best Practices](https://developer.hashicorp.com/terraform/tutorials/best-practices)