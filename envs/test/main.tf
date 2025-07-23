provider "azurerm" {
  features {}
  skip_provider_registration = true
}

module "infrastructure" {
  source              = "../../modules/infrastructure"
  location            = "westeurope"
  env                 = "test"
  resource_group_name = "cvresourcegroup-test"
  function_app_name   = "cvscannerfunc-test"
  static_web_name     = "cvstaticweb-test"
  storage_account_name = "cvstorageaccttest"
}
