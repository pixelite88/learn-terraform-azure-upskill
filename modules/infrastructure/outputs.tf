output "function_app_url" {
  value = azurerm_linux_function_app.backend.default_hostname
}

output "static_site_url" {
  value = azurerm_static_web_app.frontend.default_host_name
}