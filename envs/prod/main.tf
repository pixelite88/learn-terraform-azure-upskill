provider "azurerm" {
  features {}
  skip_provider_registration = true
}

module "infrastructure" {
  source              = "../../modules/infrastructure"
  location            = "westeurope"
  env                 = "prod"
  resource_group_name = "cvresourcegroup-prod"
  function_app_name   = "cvscannerfunc-prod"
  static_web_name     = "cvstaticweb-prod"
  storage_account_name = "cvstorageacctprod"
}
