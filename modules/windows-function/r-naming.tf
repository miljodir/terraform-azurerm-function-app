locals {
  unique_prefix = var.use_caf_naming ? compact(["${var.workload}${var.unique}", local.name_suffix]) : compact([var.workload, local.name_suffix])
}

data "azurecaf_name" "application_insights" {
  resource_type = "azurerm_application_insights"
  prefixes      = compact([var.workload, local.name_suffix])
  suffixes      = compact([var.use_caf_naming ? "" : "ai"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "function_app" {
  resource_type = "azurerm_function_app"
  prefixes      = local.unique_prefix
  suffixes      = compact([var.use_caf_naming ? "" : "fa"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "storage_account" {
  resource_type = "azurerm_storage_account"
  prefixes      = local.unique_prefix
  suffixes      = compact(["deploy"])
  use_slug      = var.use_caf_naming
  clean_input   = true
}
