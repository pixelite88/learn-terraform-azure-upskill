output "function_app_url" {
  value       = "https://${azurerm_linux_function_app.backend.default_hostname}"
  description = "Publiczny URL Function App"
}