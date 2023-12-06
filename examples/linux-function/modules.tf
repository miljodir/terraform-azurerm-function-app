
resource "azurerm_resource_group" "rg" {
  name     = "my-rg"
  location = "norwayeast"
}


### Linux
module "function_app_linux" {
  source  = "miljodir/function-app/azurerm"
  version = "x.x.x"

  workload            = var.workload
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  name_prefix = "hello"

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

  storage_account_identity_type = "SystemAssigned"

}
