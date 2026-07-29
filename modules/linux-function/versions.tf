terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "> 4.0, < 6.0"
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
