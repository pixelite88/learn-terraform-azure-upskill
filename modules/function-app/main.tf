
# 5. Function App
resource "azurerm_linux_function_app" "backend" {
  name                       = var.function_app_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = var.service_plan_id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
 
  site_config { # required
    application_stack {
      node_version = "18"
    }
  }
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = var.instrumentation_key
    FUNCTIONS_EXTENSION_VERSION    = "~4"
    FUNCTIONS_WORKER_RUNTIME       = "node"
  }
}