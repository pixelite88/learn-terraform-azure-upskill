locals {
  repository_url    = "https://github.com/pixelite88/azure-fundamentals-upskill"
  repository_branch = "main"
}

resource "azurerm_static_web_app" "frontend" {
  name                = var.static_web_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  repository_url      = local.repository_url
  repository_branch   = local.repository_branch
  repository_token    = var.repository_token
}
