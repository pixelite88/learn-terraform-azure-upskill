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

provider "azurerm" {
  features {}
  # skip_provider_registration = true
  subscription_id = var.subscription_id # Wymagane, jeśli masz wiele subskrypcji
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

resource "azurerm_storage_container" "cv_safe" {
  name                  = "cv-safe" # required
  storage_account_id  = azurerm_storage_account.storage.id # required
}

resource "azurerm_storage_container" "cv_notsafe" {
  name                  = "cv-notsafe" # required
  storage_account_id  = azurerm_storage_account.storage.id # optional
}

resource "azurerm_storage_container" "cv_quarantine" {
  name                  = "cv-quarantine" # required
  storage_account_id  = azurerm_storage_account.storage.id # optional
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
  repository_token      = var.github_token
}  
