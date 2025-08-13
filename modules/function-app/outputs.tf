output "function_app_hostname" {
  value       = azurerm_linux_function_app.backend.default_hostname
  description = "Domyślny host Function App"
}

output "function_app_url" {
  value       = "https://${azurerm_linux_function_app.backend.default_hostname}"
  description = "Adres Function App"
}