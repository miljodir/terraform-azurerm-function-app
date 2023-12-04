data "azurecaf_name" "function_app" {
  name          = var.client_name
  resource_type = "azurerm_function_app"
  prefixes      = local.function_name_prefix == "" ? null : [local.function_name_prefix]
  suffixes      = compact([var.client_name, var.location_short, var.environment, local.name_suffix, var.use_caf_naming ? "" : "func"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "application_insights" {
  name          = var.client_name
  resource_type = "azurerm_application_insights"
  prefixes      = local.ai_name_prefix == "" ? null : [local.ai_name_prefix]
  suffixes      = compact([var.client_name, var.location_short, var.environment, local.name_suffix, var.use_caf_naming ? "" : "ai"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}
