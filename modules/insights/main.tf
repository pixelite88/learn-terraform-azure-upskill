resource "azurerm_application_insights" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}

output "instrumentation_key" {
  value     = azurerm_application_insights.main.instrumentation_key
  sensitive = true
}

output "app_id" {
  value = azurerm_application_insights.main.app_id
}