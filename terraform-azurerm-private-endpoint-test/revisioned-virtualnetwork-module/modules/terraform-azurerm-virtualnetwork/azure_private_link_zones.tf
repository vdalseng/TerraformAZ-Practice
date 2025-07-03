# Azure Private Link DNS Zones - Official Microsoft Subresource Names
# Updated: 2025-Q1 | Uses official Azure documentation subresource names
# Source: https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns
#
# 🎯 SOLUTION TO SUBRESOURCE NAME CONFLICTS:
# This module now uses the official Microsoft-documented subresource names exactly as they are.
# For conflicting names (like "account" used by both Cognitive Services and Purview), the module's
# main.tf contains smart resolution logic that examines the resource_id to determine the correct DNS zone.
#
# 📋 USAGE EXAMPLES:
# ✅ Use official Microsoft subresource names exactly as documented:
# 
# private_endpoint_configs = {
#   "storage" = {
#     resource_id       = azurerm_storage_account.example.id
#     subresource_names = ["blob"]                              # Official name from Microsoft docs
#   }
#   "cognitive" = {
#     resource_id       = azurerm_cognitive_account.example.id
#     subresource_names = ["account"]                           # Auto-resolves to cognitiveservices DNS
#   }
#   "purview" = {
#     resource_id       = azurerm_purview_account.example.id
#     subresource_names = ["account"]                           # Auto-resolves to purview DNS
#   }
#   "keyvault" = {
#     resource_id       = azurerm_key_vault.example.id
#     subresource_names = ["vault"]                             # Official name from Microsoft docs
#   }
# }
#
# 🧠 SMART CONFLICT RESOLUTION:
# For the "account" subresource (used by multiple services), the module automatically
# determines the correct DNS zone by examining the resource_id pattern:
# - Contains "Microsoft.CognitiveServices" → privatelink.cognitiveservices.azure.com
# - Contains "Microsoft.Purview" → privatelink.purview.azure.com

locals {
  # Official Azure service subresource names to DNS zones mapping
  # Based on Microsoft documentation - uses exact subresource names from Azure docs
  service_dns_zones = {
    
    # ==========================================
    # STORAGE SERVICES
    # ==========================================
    "blob"                = "privatelink.blob.core.windows.net"
    "blob_secondary"      = "privatelink.blob.core.windows.net"
    "dfs"                 = "privatelink.dfs.core.windows.net"
    "dfs_secondary"       = "privatelink.dfs.core.windows.net"
    "file"                = "privatelink.file.core.windows.net"
    "queue"               = "privatelink.queue.core.windows.net"
    "queue_secondary"     = "privatelink.queue.core.windows.net"
    "table"               = "privatelink.table.core.windows.net"
    "table_secondary"     = "privatelink.table.core.windows.net"
    "web"                 = "privatelink.web.core.windows.net"
    "web_secondary"       = "privatelink.web.core.windows.net"
    "disks"               = "privatelink.blob.core.windows.net"     # Azure Managed Disks
    "volumegroup"         = "privatelink.blob.core.windows.net"     # Azure Elastic SAN
    "afs"                 = "privatelink.afs.azure.net"             # Azure File Sync
    
    # ==========================================
    # DATABASE SERVICES
    # ==========================================
    "sqlServer"           = "privatelink.database.windows.net"
    "managedInstance"     = "privatelink.database.windows.net"     # Simplified (region substitution handled elsewhere)
    "postgresqlServer"    = "privatelink.postgres.database.azure.com"
    "mysqlServer"         = "privatelink.mysql.database.azure.com"
    "mariadbServer"       = "privatelink.mariadb.database.azure.com"
    "redisCache"          = "privatelink.redis.cache.windows.net"
    "redisEnterprise"     = "privatelink.redisenterprise.cache.azure.net"
    
    # Cosmos DB subresources (exact Microsoft names - note capitalization)
    "Sql"                 = "privatelink.documents.azure.com"
    "MongoDB"             = "privatelink.mongo.cosmos.azure.com"
    "Cassandra"           = "privatelink.cassandra.cosmos.azure.com"
    "Gremlin"             = "privatelink.gremlin.cosmos.azure.com"
    "Table"               = "privatelink.table.cosmos.azure.com"
    "Analytical"          = "privatelink.analytics.cosmos.azure.com"
    "coordinator"         = "privatelink.postgres.cosmos.azure.com"
    
    # ==========================================
    # SECURITY & KEY MANAGEMENT
    # ==========================================
    "vault"               = "privatelink.vaultcore.azure.net"
    "managedhsm"          = "privatelink.managedhsm.azure.net"
    "configurationStores" = "privatelink.azconfig.io"               # App Configuration
    "standard"            = "privatelink.attest.azure.net"          # Azure Attestation
    
    # ==========================================
    # COMPUTE & WEB SERVICES  
    # ==========================================
    "sites"               = "privatelink.azurewebsites.net"         # App Service, Functions
    "registry"            = "privatelink.azurecr.io"                # Container Registry
    "staticSites"         = "privatelink.azurestaticapps.net"       # Static Web Apps
    "searchService"       = "privatelink.search.windows.net"        # Azure Search
    "batchAccount"        = "privatelink.batch.azure.com"           # Simplified
    "nodeManagement"      = "privatelink.batch.azure.com"           # Simplified
    
    # ==========================================
    # MESSAGING & INTEGRATION
    # ==========================================
    "namespace"           = "privatelink.servicebus.windows.net"    # Service Bus, Event Hubs, Relay
    "topic"               = "privatelink.eventgrid.azure.net"       # Event Grid Topic
    "domain"              = "privatelink.eventgrid.azure.net"       # Event Grid Domain
    "partnernamespace"    = "privatelink.eventgrid.azure.net"       # Event Grid Partner Namespace
    "topicSpace"          = "privatelink.ts.eventgrid.azure.net"    # Event Grid Namespace Topic Space
    
    # API Management subresources (exact Microsoft names - note capitalization)
    "Gateway"             = "privatelink.azure-api.net"
    "Management"          = "privatelink.azure-api.net"
    "Portal"              = "privatelink.azure-api.net"
    "Scm"                 = "privatelink.azure-api.net"
    
    # ==========================================
    # AI & MACHINE LEARNING
    # ==========================================
    # NOTE: "account" subresource is handled by smart resolution in main.tf
    # - Microsoft.CognitiveServices/accounts → privatelink.cognitiveservices.azure.com
    # - Microsoft.Purview/accounts → privatelink.purview.azure.com
    "amlworkspace"        = "privatelink.api.azureml.ms"
    
    # ==========================================
    # IOT & EDGE
    # ==========================================
    "iotHub"              = "privatelink.azure-devices.net"
    "iotDps"              = "privatelink.azure-devices-provisioning.net"
    "iotApp"              = "privatelink.azureiotcentral.com"        # IoT Central
    "API"                 = "privatelink.digitaltwins.azure.net"     # Digital Twins
    "DeviceUpdate"        = "privatelink.api.adu.microsoft.com"      # Device Update for IoT
    
    # ==========================================
    # ANALYTICS & DATA
    # ==========================================
    "Sql"                 = "privatelink.sql.azuresynapse.net"      # Synapse Analytics SQL
    "SqlOnDemand"         = "privatelink.sql.azuresynapse.net"      # Synapse Analytics SQL On-Demand
    "Dev"                 = "privatelink.dev.azuresynapse.net"      # Synapse Analytics Dev
    "Web"                 = "privatelink.azuresynapse.net"          # Synapse Studio
    "dataFactory"         = "privatelink.datafactory.azure.net"    # Data Factory
    "portal"              = "privatelink.adf.azure.com"            # Data Factory Portal
    "cluster"             = "privatelink.kusto.windows.net"        # Data Explorer (simplified)
    "gateway"             = "privatelink.azurehdinsight.net"       # HDInsight
    "headnode"            = "privatelink.azurehdinsight.net"       # HDInsight
    "databricks_ui_api"   = "privatelink.azuredatabricks.net"      # Databricks
    "browser_authentication" = "privatelink.azuredatabricks.net"   # Databricks
    "tenant"              = "privatelink.analysis.windows.net"     # Power BI
    
    # ==========================================
    # MONITORING & MANAGEMENT
    # ==========================================
    "azuremonitor"        = "privatelink.monitor.azure.com"
    "Webhook"             = "privatelink.azure-automation.net"     # Automation
    "DSCAndHybridWorker"  = "privatelink.azure-automation.net"     # Automation
    "AzureBackup"         = "privatelink.backup.windowsazure.com"  # Simplified
    "AzureBackup_secondary" = "privatelink.backup.windowsazure.com" # Simplified
    "AzureSiteRecovery"   = "privatelink.siterecovery.windowsazure.com"
    "Default"             = "privatelink.prod.migration.windowsazure.com"  # Azure Migrate
    "ResourceManagement"  = "privatelink.azure.com"               # ARM
    "grafana"             = "privatelink.grafana.azure.com"        # Managed Grafana
    
    # ==========================================
    # MEDIA & CONTENT DELIVERY
    # ==========================================
    "keydelivery"         = "privatelink.media.azure.net"
    "liveevent"           = "privatelink.media.azure.net"
    "streamingendpoint"   = "privatelink.media.azure.net"
    "signalr"             = "privatelink.service.signalr.net"
    "webpubsub"           = "privatelink.webpubsub.azure.com"
    
    # ==========================================
    # OTHER SERVICES
    # ==========================================
    "hybridcompute"       = "privatelink.his.arc.azure.com"        # Azure Arc
    "Bot"                 = "privatelink.directline.botframework.com"
    "Token"               = "privatelink.token.botframework.com"
    "global"              = "privatelink-global.wvd.microsoft.com" # Azure Virtual Desktop
    "feed"                = "privatelink.wvd.microsoft.com"        # Azure Virtual Desktop
    "connection"          = "privatelink.wvd.microsoft.com"        # Azure Virtual Desktop
    "healthcareworkspace" = "privatelink.azurehealthcareapis.com"  # Health Data Services
  }
}
