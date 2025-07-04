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
    "disks"               = "privatelink.blob.core.windows.net"
    "volumegroup"         = "privatelink.blob.core.windows.net"
    "afs"                 = "privatelink.afs.azure.net"
    
    # ==========================================
    # DATABASE SERVICES
    # ==========================================
    "sqlServer"           = "privatelink.database.windows.net"
    "managedInstance"     = "privatelink.database.windows.net"
    "postgresqlServer"    = "privatelink.postgres.database.azure.com"
    "mysqlServer"         = "privatelink.mysql.database.azure.com"
    "mariadbServer"       = "privatelink.mariadb.database.azure.com"
    "redisCache"          = "privatelink.redis.cache.windows.net"
    "redisEnterprise"     = "privatelink.redisenterprise.cache.azure.net"
    
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
    "configurationStores" = "privatelink.azconfig.io"
    "standard"            = "privatelink.attest.azure.net"
    
    # ==========================================
    # COMPUTE & WEB SERVICES  
    # ==========================================
    "sites"               = "privatelink.azurewebsites.net"
    "registry"            = "privatelink.azurecr.io"
    "staticSites"         = "privatelink.azurestaticapps.net"
    "searchService"       = "privatelink.search.windows.net"
    "batchAccount"        = "privatelink.batch.azure.com"
    "nodeManagement"      = "privatelink.batch.azure.com"
    
    # ==========================================
    # MESSAGING & INTEGRATION
    # ==========================================
    "namespace"           = "privatelink.servicebus.windows.net"
    "topic"               = "privatelink.eventgrid.azure.net"
    "domain"              = "privatelink.eventgrid.azure.net"
    "partnernamespace"    = "privatelink.eventgrid.azure.net"
    "topicSpace"          = "privatelink.ts.eventgrid.azure.net"
    
    "Gateway"             = "privatelink.azure-api.net"
    "Management"          = "privatelink.azure-api.net"
    "Portal"              = "privatelink.azure-api.net"
    "Scm"                 = "privatelink.azure-api.net"
    
    # ==========================================
    # AI & MACHINE LEARNING
    # ==========================================
    "amlworkspace"        = "privatelink.api.azureml.ms"
    
    # ==========================================
    # IOT & EDGE
    # ==========================================
    "iotHub"              = "privatelink.azure-devices.net"
    "iotDps"              = "privatelink.azure-devices-provisioning.net"
    "iotApp"              = "privatelink.azureiotcentral.com"
    "API"                 = "privatelink.digitaltwins.azure.net"
    "DeviceUpdate"        = "privatelink.api.adu.microsoft.com"
    
    # ==========================================
    # ANALYTICS & DATA
    # ==========================================
    "Sql"                 = "privatelink.sql.azuresynapse.net"
    "SqlOnDemand"         = "privatelink.sql.azuresynapse.net"
    "Dev"                 = "privatelink.dev.azuresynapse.net"
    "Web"                 = "privatelink.azuresynapse.net"
    "dataFactory"         = "privatelink.datafactory.azure.net"
    "portal"              = "privatelink.adf.azure.com"
    "cluster"             = "privatelink.kusto.windows.net"
    "gateway"             = "privatelink.azurehdinsight.net"
    "headnode"            = "privatelink.azurehdinsight.net"
    "databricks_ui_api"   = "privatelink.azuredatabricks.net"
    "browser_authentication" = "privatelink.azuredatabricks.net"
    "tenant"              = "privatelink.analysis.windows.net"
    
    # ==========================================
    # MONITORING & MANAGEMENT
    # ==========================================
    "azuremonitor"        = "privatelink.monitor.azure.com"
    "Webhook"             = "privatelink.azure-automation.net"
    "DSCAndHybridWorker"  = "privatelink.azure-automation.net"
    "AzureBackup"         = "privatelink.backup.windowsazure.com"
    "AzureBackup_secondary" = "privatelink.backup.windowsazure.com"
    "AzureSiteRecovery"   = "privatelink.siterecovery.windowsazure.com"
    "Default"             = "privatelink.prod.migration.windowsazure.com"
    "ResourceManagement"  = "privatelink.azure.com"
    "grafana"             = "privatelink.grafana.azure.com"
    
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
    "hybridcompute"       = "privatelink.his.arc.azure.com"
    "Bot"                 = "privatelink.directline.botframework.com"
    "Token"               = "privatelink.token.botframework.com"
    "global"              = "privatelink-global.wvd.microsoft.com"
    "feed"                = "privatelink.wvd.microsoft.com"
    "connection"          = "privatelink.wvd.microsoft.com"
    "healthcareworkspace" = "privatelink.azurehealthcareapis.com"
  }
}
