provider "azurerm" {
  features {}
  #skip_provider_registration = true
}

locals {
  env = "prod"
}

module "infrastructure" {
  source              = "../../modules/infrastructure"
  subscription_id     = var.subscription_id 
  location            = var.location
  env                 = local.env
  resource_group_name   = "cvresourcegroup-${local.env}"
  function_app_name     = "cvscannerfunc-${local.env}"
  static_web_app_name   = "cvstaticweb-${local.env}"
  storage_account_name  = "cvstorageacct${local.env}"
  github_token          = var.github_token
}
