
output "instrumentation_key" {
  value = module.insights.instrumentation_key
  sensitive = true
}

output "app_id" {
  value = module.insights.app_id
}

output "function_app_url" {
  value       = module.function-app.function_app_url
  description = "Publiczny URL Function App"
}

output "static_web_app_url" {
  value       = module.static-web-app.static_web_app_url
  description = "Publiczny URL Static Web App"
}

