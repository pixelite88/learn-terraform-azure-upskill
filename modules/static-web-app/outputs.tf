output "static_web_app_url" {
  value       = "https://${azurerm_static_web_app.frontend.name}.azurewebsites.net"
  description = "Publiczny URL Static Web App"
}
