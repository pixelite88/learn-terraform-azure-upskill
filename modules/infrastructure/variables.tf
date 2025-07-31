variable "resource_group_name" {
  description = "cvresourcegroup2307"
  type        = string
}

variable "location" {
  description = "westeurope"
  type        = string
}

variable "storage_account_name" {
  description = "cvsecurestorage2307"
  type        = string
}

variable "function_app_name" {
  description = "cvscannerfunc2307"
  type        = string
}

variable "static_web_app_name" {
  description = "cvsecurefrontend2307"
  type        = string
}

variable "env" {
  type        = string
  description = "Environment name (eg. dev, test, prod)"
}