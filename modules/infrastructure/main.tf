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
}

# 2. App Service Plan (dla Function App)
resource "azurerm_service_plan" "main" {
  name                = "function-app-plan" # required
  location            = azurerm_resource_group.main.location #required
  resource_group_name = azurerm_resource_group.main.name # required
  os_type             = "Linux" #required Linux / Windows /  WindowsContainer
  sku_name            = "Y1" #required / Plan zużycia
}

# Moving frontend
moved {
 from =  module.infrastructure.azurerm_static_web_app.frontend
 to = module.static_web_app.azurerm_static_web_app.frontend
}
# Moving backend
moved {
  from = module.infrastructure.azurerm_linux_function_app.backend
  to = module.function_app.azurerm_linux_function_app.backend
}

# Moving storage account
moved {
  from = module.infrastructure.azurerm_storage_account.storage
  to = module.storage.azurerm_storage_account.storage
}

# Moving storage container
moved {
  from = module.infrastructure.azurerm_storage_container.cv
  to = module.storage.azurerm_storage_container.cv
}

# Moving App Insights
moved {
  from = module.infrastructure.azurerm_application_insights.main
  to = module.insights.azurerm_application_insights.main
}
module "static-web-app" {
  source              = "../static-web-app"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  static_web_app_name = var.static_web_app_name
  repository_token    = data.azurerm_key_vault_secret.github_token.value
}

module "function-app" {
  source                     = "../function-app"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = var.location
  function_app_name          = var.function_app_name
  service_plan_id            = azurerm_service_plan.main.id
  storage_account_name       = module.storage.storage_account_name
  storage_account_access_key = module.storage.primary_access_key
  instrumentation_key        = module.insights.instrumentation_key
}

module "storage" {
  source = "../storage"
  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  storage_account_name = var.storage_account_name
}

module "insights" {
  source               = "../insights"
  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
}
