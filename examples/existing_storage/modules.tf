data "azurerm_client_config" "current" {}


resource "azurerm_resource_group" "rg" {
  name     = "my-rg"
  location = "norwayeast"
}


module "functions_storage_account" {
  source  = "miljodir/storage-account/azurerm"
  version = "~> 1.0"
  providers = {
    azurerm       = azurerm
    azurerm.p-dns = azurerm.p-dns
  }

  resource_group_name                  = azurerm_resource_group.rg.name
  storage_account_name                 = "myname"
  account_kind                         = "StorageV2"
  blob_soft_delete_retention_days      = 7
  container_soft_delete_retention_days = 7
  is_hns_enabled                       = false
  min_tls_version                      = "TLS1_2"
  shared_access_key_enabled            = false
  sku_name                             = "Standard_LRS"
  subnet_id                            = "mysubnet"
  public_network_access_enabled        = false
  allow_nested_items_to_be_public      = false

  private_endpoints = [
    "blob",
  ]
}

module "function_app" {
  source  = "miljodir/function-app/azurerm"
  version = "x.x.x"

  workload            = var.workload
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type              = "Linux"
  function_app_version = 4
  function_app_site_config = {
    application_stack = {
      dotnet_version = "8.0"
    }
  }

  function_app_application_settings = {
    "tracker_id"      = "AJKGDFJKHFDS"
    "backend_api_url" = "https://backend.domain.tld/api"
  }

  storage_uses_managed_identity = true

  use_existing_storage_account = true
  storage_account_id           = module.functions_storage_account.storage_account.id
  storage_subnet_id            = "mysubnetid"

}
