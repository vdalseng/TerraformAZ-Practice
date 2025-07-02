# Azure Private Link DNS Zones - Comprehensive List
# Updated: 2025-Q1 (update quarterly with new Azure services)
# Source: https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns

locals {
  # Complete mapping of Azure service subresource names to their private link DNS zones
  service_dns_zones = {
    
    # ==========================================
    # STORAGE SERVICES
    # ==========================================
    
    # Azure Storage Account
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
    
    # Azure Storage Sync
    "afs"                 = "privatelink.afs.azure.net"
    
    # ==========================================
    # DATABASE SERVICES
    # ==========================================
    
    # Azure SQL Database
    "sqlServer"           = "privatelink.database.windows.net"
    
    # Azure Database for PostgreSQL
    "postgresqlServer"    = "privatelink.postgres.database.azure.com"
    
    # Azure Database for MySQL
    "mysqlServer"         = "privatelink.mysql.database.azure.com"
    
    # Azure Database for MariaDB
    "mariadbServer"       = "privatelink.mariadb.database.azure.com"
    
    # Azure Cache for Redis
    "redisCache"          = "privatelink.redis.cache.windows.net"
    
    # Azure Cosmos DB
    "sql"                 = "privatelink.documents.azure.com"
    "mongodb"             = "privatelink.mongo.cosmos.azure.com"
    "cassandra"           = "privatelink.cassandra.cosmos.azure.com"
    "gremlin"             = "privatelink.gremlin.cosmos.azure.com"
    "table"               = "privatelink.table.cosmos.azure.com"
    "analytical"          = "privatelink.analytics.cosmos.azure.com"
    
    # ==========================================
    # SECURITY & KEY MANAGEMENT
    # ==========================================
    
    # Azure Key Vault
    "vault"               = "privatelink.vaultcore.azure.net"
    
    # Azure Managed HSM
    "managedhsm"          = "privatelink.managedhsm.azure.net"
    
    # ==========================================
    # COMPUTE & WEB SERVICES
    # ==========================================
    
    # Azure App Service
    "sites"               = "privatelink.azurewebsites.net"
    "scm"                 = "scm.privatelink.azurewebsites.net"
    
    # Azure Static Web Apps
    "staticSites"         = "privatelink.azurestaticapps.net"
    
    # Azure Functions
    "function"            = "privatelink.azurewebsites.net"
    
    # Azure Container Registry
    "registry"            = "privatelink.azurecr.io"
    
    # Azure Kubernetes Service
    "management"          = "privatelink.{region}.azmk8s.io"
    
    # ==========================================
    # MESSAGING & INTEGRATION
    # ==========================================
    
    # Azure Service Bus
    "namespace"           = "privatelink.servicebus.windows.net"
    
    # Azure Event Hubs
    "namespace"           = "privatelink.servicebus.windows.net"
    
    # Azure Event Grid
    "topic"               = "privatelink.eventgrid.azure.net"
    "domain"              = "privatelink.eventgrid.azure.net"
    
    # Azure Relay
    "namespace"           = "privatelink.servicebus.windows.net"
    
    # ==========================================
    # AI & MACHINE LEARNING
    # ==========================================
    
    # Azure Cognitive Services
    "account"             = "privatelink.cognitiveservices.azure.com"
    
    # Azure OpenAI Service
    "account"             = "privatelink.openai.azure.com"
    
    # Azure Machine Learning
    "workspace"           = "privatelink.api.azureml.ms"
    "notebooks"           = "privatelink.notebooks.azure.net"
    
    # Azure Search
    "searchService"       = "privatelink.search.windows.net"
    
    # ==========================================
    # IOT & EDGE
    # ==========================================
    
    # Azure IoT Hub
    "iotHub"              = "privatelink.azure-devices.net"
    "servicebus"          = "privatelink.servicebus.windows.net"
    
    # Azure IoT Central
    "iotApp"              = "privatelink.azureiotcentral.com"
    
    # Azure IoT Device Provisioning Service
    "iotDps"              = "privatelink.azure-devices-provisioning.net"
    
    # Azure Digital Twins
    "API"                 = "privatelink.digitaltwins.azure.net"
    
    # ==========================================
    # ANALYTICS & DATA
    # ==========================================
    
    # Azure Synapse Analytics
    "sql"                 = "privatelink.sql.azuresynapse.net"
    "sqlOnDemand"         = "privatelink.sql.azuresynapse.net"
    "dev"                 = "privatelink.dev.azuresynapse.net"
    
    # Azure Data Factory
    "dataFactory"         = "privatelink.datafactory.azure.net"
    "portal"              = "privatelink.adf.azure.com"
    
    # Azure HDInsight
    "headnode"            = "privatelink.azurehdinsight.net"
    "gateway"             = "privatelink.azurehdinsight.net"
    
    # Azure Data Lake Analytics
    "azuredatalakeanalytics" = "privatelink.azuredatalakeanalytics.net"
    
    # Azure Stream Analytics
    "streaming"           = "privatelink.asazure.windows.net"
    
    # Azure Purview
    "account"             = "privatelink.purview.azure.com"
    "portal"              = "privatelink.purviewstudio.azure.com"
    
    # ==========================================
    # MONITORING & MANAGEMENT
    # ==========================================
    
    # Azure Monitor
    "azuremonitor"        = "privatelink.monitor.azure.com"
    "oms"                 = "privatelink.oms.opinsights.azure.com"
    "ods"                 = "privatelink.ods.opinsights.azure.com"
    "agentsvc"            = "privatelink.agentsvc.azure-automation.net"
    
    # Azure Automation
    "automation"          = "privatelink.azure-automation.net"
    
    # Azure Backup
    "backup"              = "privatelink.{region}.backup.windowsazure.com"
    
    # Azure Site Recovery
    "siterecovery"        = "privatelink.siterecovery.windowsazure.com"
    
    # ==========================================
    # MEDIA & CONTENT DELIVERY
    # ==========================================
    
    # Azure Media Services
    "keydelivery"         = "privatelink.media.azure.net"
    "liveevent"           = "privatelink.media.azure.net"
    "streamingendpoint"   = "privatelink.media.azure.net"
    
    # Azure SignalR Service
    "signalr"             = "privatelink.service.signalr.net"
    
    # Azure Web PubSub
    "webpubsub"           = "privatelink.webpubsub.azure.com"
    
    # ==========================================
    # GOVERNANCE & COMPLIANCE
    # ==========================================
    
    # Azure API Management
    "gateway"             = "privatelink.azure-api.net"
    "management"          = "privatelink.azure-api.net"
    "portal"              = "privatelink.azure-api.net"
    "scm"                 = "privatelink.azure-api.net"
    
    # Azure Configuration Manager
    "configurationStores" = "privatelink.azconfig.io"
    
    # ==========================================
    # DEVELOPER TOOLS
    # ==========================================
    
    # Azure DevOps
    "vsrm"                = "privatelink.vstudio.com"
    "vssps"               = "privatelink.vstudio.com"
    
    # Azure DevTest Labs
    "labCenter"           = "privatelink.labcenter.ms"
    
    # ==========================================
    # MIGRATION & HYBRID
    # ==========================================
    
    # Azure Migrate
    "migrate"             = "privatelink.prod.migration.windowsazure.com"
    
    # Azure Database Migration Service
    "dms"                 = "privatelink.dms.azure.com"
    
    # ==========================================
    # NETWORKING
    # ==========================================
    
    # Azure DNS
    "dns"                 = "privatelink.azure-dns.com"
    
    # Azure Firewall
    "azurefirewall"       = "privatelink.azure-firewall.net"
    
    # ==========================================
    # BLOCKCHAIN
    # ==========================================
    
    # Azure Blockchain Service
    "cordaRpc"            = "privatelink.blockchain.azure.com"
    "cordaRpcTls"         = "privatelink.blockchain.azure.com"
    
    # ==========================================
    # BATCH & HPC
    # ==========================================
    
    # Azure Batch
    "batchAccount"        = "privatelink.{region}.batch.azure.com"
    "nodeManagement"      = "privatelink.{region}.batch.azure.com"
    
    # ==========================================
    # MIXED REALITY
    # ==========================================
    
    # Azure Remote Rendering
    "remoterendering"     = "privatelink.mixedreality.azure.com"
    
    # Azure Spatial Anchors
    "spatialanchors"      = "privatelink.mixedreality.azure.com"
    
    # ==========================================
    # POWER PLATFORM
    # ==========================================
    
    # Power BI
    "powerbi"             = "privatelink.analysis.windows.net"
    
    # ==========================================
    # REGIONAL SERVICES (requires region substitution)
    # ==========================================
    
    # Note: Some services require region-specific DNS zones
    # Use terraform's replace() function to substitute {region} with actual region
    # Example: replace(local.all_azure_private_link_zones["backup"], "{region}", var.region)
  }
}
