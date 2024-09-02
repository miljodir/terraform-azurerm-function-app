terraform {
  required_version = "~> 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.1"
    }
  }
}

provider "azurerm" {
  features {}

  storage_use_azuread = true
}
