output "function_app_url" {
  value       = "https://${azurerm_linux_function_app.backend.name}.azurewebsites.net"
  description = "Publiczny URL Function App"
}