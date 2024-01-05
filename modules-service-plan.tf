# Service Plan
module "service_plan" {
  for_each = toset(var.service_plan_id == null ? ["enabled"] : [])
  source   = "miljodir/app-service-plan/azurerm"
  version  = "~> 1.0"

  resource_group_name = var.resource_group_name
  workload            = var.workload
  location            = var.location
  location_short      = var.location_short

  use_caf_naming                  = var.use_caf_naming
  name_prefix                     = var.name_prefix
  name_suffix                     = var.name_suffix
  custom_name                     = var.service_plan_custom_name
  custom_diagnostic_settings_name = var.custom_diagnostic_settings_name

  os_type  = lower(var.os_type) == "container" ? "Linux" : var.os_type
  sku_name = var.sku_name

  app_service_environment_id   = var.app_service_environment_id
  worker_count                 = var.worker_count
  maximum_elastic_worker_count = var.maximum_elastic_worker_count
  per_site_scaling_enabled     = var.per_site_scaling_enabled

  logs_destinations_ids   = var.logs_destinations_ids
  logs_categories         = var.logs_categories
  logs_metrics_categories = var.logs_metrics_categories

  default_tags_enabled = var.default_tags_enabled

  extra_tags = merge(
    var.extra_tags,
    var.service_plan_extra_tags,
    local.default_tags
  )
}

moved {
  from = module.service_plan
  to   = module.service_plan["enabled"]
}
