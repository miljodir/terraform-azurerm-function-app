terraform {
  required_version = ">= 1.3"

  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 3.36"
      configuration_aliases = [azurerm.p-dns]
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2, >= 1.2.22"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}
