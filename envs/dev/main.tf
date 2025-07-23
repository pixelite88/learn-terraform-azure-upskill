provider "azurerm" {
  features {}
  skip_provider_registration = true
}

module "infrastructure" {
  source              = "../../modules/infrastructure"
  location            = "westeurope"
  env                 = "dev"
  resource_group_name   = "cvresourcegroup-dev"
  function_app_name     = "cvscannerfunc-dev"
  static_web_app_name   = "cvstaticweb-dev"
  storage_account_name  = "cvstorageacctdev"
  github_token          = ""
}
