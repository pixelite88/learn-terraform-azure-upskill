
output "instrumentation_key" {
  value = module.insights.instrumentation_key
  sensitive = true
}

output "app_id" {
  value = module.insights.app_id
}
