# Service Plan
module "service_plan" {
  source  = "claranet/app-service-plan/azurerm"
  version = "~> 6.2.0"

  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  resource_group_name = var.resource_group_name
  location            = var.location
  location_short      = var.location_short

  use_caf_naming = var.use_caf_naming
  name_prefix    = var.name_prefix
  name_suffix    = var.name_suffix
  custom_name    = var.service_plan_custom_name

  os_type  = var.os_type
  sku_name = var.sku_name

  app_service_environment_id   = var.app_service_environment_id
  worker_count                 = var.worker_count
  maximum_elastic_worker_count = var.maximum_elastic_worker_count
  per_site_scaling_enabled     = var.per_site_scaling_enabled

  logs_destinations_ids = var.logs_destinations_ids

  default_tags_enabled = var.default_tags_enabled

  extra_tags = merge(
    var.extra_tags,
    var.service_plan_extra_tags,
    local.default_tags,
  )
}

moved {
  from = module.app_service_plan
  to   = module.service_plan
}
