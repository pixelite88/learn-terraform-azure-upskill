# Terraform configuration for Azure Static Web App, Function App and Storage
# Dostawca Azure (Provider):
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.96.0"
    }
  }
  required_version = ">= 1.5.0"
}

# 1. Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name # required
  location = var.location # required
  # tags = "" optional
  # managed_by = "" optional
}

# 2. App Service Plan (dla Function App)
resource "azurerm_service_plan" "main" {
  name                = "function-app-plan" # required
  location            = azurerm_resource_group.main.location #required
  resource_group_name = azurerm_resource_group.main.name # required
  os_type             = "Linux" #required Linux / Windows /  WindowsContainer
  sku_name            = "Y1" #required / Plan zużycia
}

# 3. Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name # required
  resource_group_name      = azurerm_resource_group.main.name  # required
  location                 = azurerm_resource_group.main.location  # required
  account_tier             = "Standard"  # required
  account_replication_type = "LRS" # required
}

resource "azurerm_storage_container" "cv" {
  for_each = toset(["cv-safe", "cv-notsafe", "cv-quarantine"])
  name                  = each.value 
  storage_account_id  = azurerm_storage_account.storage.id # required
}

moved {
  from = azurerm_storage_container.cv_notsafe
  to = azurerm_storage_container.cv["cv-notsafe"]
}

moved {
  from = azurerm_storage_container.cv_safe
  to = azurerm_storage_container.cv["cv-safe"]
}

moved {
  from = azurerm_storage_container.cv_quarantine
  to = azurerm_storage_container.cv["cv-quarantine"]
}

# 4. Application Insights
resource "azurerm_application_insights" "main" {
  name                = "cvscannerappinsights2307" # required
  location            = azurerm_resource_group.main.location # required
  resource_group_name = azurerm_resource_group.main.name # required
  application_type    = "web" # required
}

output "instrumentation_key" {
  value = azurerm_application_insights.main.instrumentation_key
  sensitive = true
}

output "app_id" {
  value = azurerm_application_insights.main.app_id
}


# 5. Function App
resource "azurerm_linux_function_app" "backend" {
  name                       = var.function_app_name # required
  location                   = azurerm_resource_group.main.location 
  resource_group_name        = azurerm_resource_group.main.name # required
  service_plan_id            = azurerm_service_plan.main.id # required
  storage_account_name       = azurerm_storage_account.storage.name # required
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key  # required
 
  site_config { # required
    application_stack {
      node_version = "18"
    }
  }
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.main.instrumentation_key
    AzureWebJobsStorage            = azurerm_storage_account.storage.primary_connection_string
    FUNCTIONS_EXTENSION_VERSION    = "~4"
    FUNCTIONS_WORKER_RUNTIME       = "node"
  }
}

resource "azurerm_static_web_app" "frontend" {
  name                  = "static-web-deployment"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  repository_url        = "https://github.com/pixelite88/azure-fundamentals-upskill"
  repository_branch     = "main"
  repository_token      = data.azurerm_key_vault_secret.github_token.value # GitHub token from Key Vault
}

# Blob Lifecycle Management
# resource "azurerm_storage_management_policy" "main" {
  storage_account_id   = azurerm_storage_account.storage.id

  rule {
    name    = "move-to-archive-and-delete"
    enabled = true
    filters {
      prefix_match = [""]
      blob_types = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 10
        tier_to_archive_after_days_since_modification_greater_than = 50
        delete_after_days_since_modification_greater_than          = 100
      }

      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }
#}

data "azurerm_client_config" "current" {} # who's logged in now and using TF. 
