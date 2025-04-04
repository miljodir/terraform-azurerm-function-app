locals {
  function_app_public_network_access_enabled = split("-", var.workload)[0] == "d" ? true : var.function_app_public_network_access_enabled ? true : false
  scm_authorized_ips = [for ip in(local.function_app_public_network_access_enabled ? try(concat(values(module.network_vars[0].known_public_ips), var.scm_authorized_ips), (values(module.network_vars[0].known_public_ips))) : []) :
    can(regex(".*\\/\\d+$", ip)) ? ip : format("%s/32", ip)
  ]
  authorized_ips = [for ip in(local.function_app_public_network_access_enabled ? try(concat(values(module.network_vars[0].known_public_ips), var.authorized_ips), (values(module.network_vars[0].known_public_ips))) : []) :
    can(regex(".*\\/\\d+$", ip)) ? ip : format("%s/32", ip)
  ]
}

module "network_vars" {
  # private module used for public IP whitelisting
  count  = local.function_app_public_network_access_enabled == true ? 1 : 0
  source = "git@github.com:miljodir/cp-shared.git//modules/public_nw_ips?ref=public_nw_ips/v1"
}

module "linux_function" {
  for_each = toset(lower(var.os_type) == "linux" ? ["enabled"] : [])

  providers = {
    azurerm = azurerm
  }

  source = "./modules/linux-function"

  workload = var.workload

  resource_group_name = var.resource_group_name
  location            = var.location
  location_short      = var.location_short

  use_caf_naming = var.use_caf_naming
  name_prefix    = var.name_prefix
  name_suffix    = var.name_suffix

  storage_uses_managed_identity  = var.storage_uses_managed_identity
  function_app_key_vault_id      = var.function_app_key_vault_id
  skip_identity_role_assignments = var.skip_identity_role_assignments


  storage_account_name_prefix                       = var.storage_account_name_prefix
  storage_account_custom_name                       = var.storage_account_custom_name
  use_existing_storage_account                      = var.use_existing_storage_account
  storage_account_id                                = var.storage_account_id
  storage_account_enable_advanced_threat_protection = var.storage_account_enable_advanced_threat_protection
  storage_account_enable_https_traffic_only         = var.storage_account_enable_https_traffic_only
  storage_account_kind                              = var.storage_account_kind
  storage_account_min_tls_version                   = var.storage_account_min_tls_version
  storage_account_identity_type                     = var.storage_account_identity_type
  storage_account_identity_ids                      = var.storage_account_identity_ids
  storage_subnet_id                                 = var.storage_subnet_id
  storage_account_is_hns_enabled                    = var.storage_account_is_hns_enabled
  storage_private_endpoints                         = var.storage_private_endpoints
  storage_ip_rules                                  = var.storage_ip_rules

  service_plan_id = local.service_plan_id

  function_app_name_prefix                       = var.function_app_name_prefix
  function_app_custom_name                       = var.function_app_custom_name
  function_app_application_settings              = var.function_app_application_settings
  function_app_application_settings_drift_ignore = var.function_app_application_settings_drift_ignore
  function_app_version                           = var.function_app_version
  site_config                                    = var.function_app_site_config
  sticky_settings                                = var.function_app_sticky_settings
  function_app_public_network_access_enabled     = local.function_app_public_network_access_enabled
  unique                                         = var.unique

  application_insights_name_prefix                           = var.application_insights_name_prefix
  application_insights_enabled                               = var.application_insights_enabled
  application_insights_id                                    = var.application_insights_id
  application_insights_type                                  = var.application_insights_type
  application_insights_custom_name                           = var.application_insights_custom_name
  application_insights_daily_data_cap                        = var.application_insights_daily_data_cap
  application_insights_daily_data_cap_notifications_disabled = var.application_insights_daily_data_cap_notifications_disabled
  application_insights_sampling_percentage                   = var.application_insights_sampling_percentage
  application_insights_retention                             = var.application_insights_retention
  application_insights_internet_ingestion_enabled            = var.application_insights_internet_ingestion_enabled
  application_insights_internet_query_enabled                = var.application_insights_internet_query_enabled
  application_insights_ip_masking_disabled                   = var.application_insights_ip_masking_disabled
  application_insights_local_authentication_disabled         = var.application_insights_local_authentication_disabled
  application_insights_force_customer_storage_for_profiler   = var.application_insights_force_customer_storage_for_profiler
  application_insights_log_analytics_workspace_id            = var.application_insights_log_analytics_workspace_id

  identity_type = var.identity_type
  identity_ids  = var.identity_ids

  logs_destinations_ids   = var.logs_destinations_ids
  logs_categories         = var.logs_categories
  logs_metrics_categories = var.logs_metrics_categories

  authorized_ips                          = local.authorized_ips
  authorized_service_tags                 = var.authorized_service_tags
  authorized_subnet_ids                   = var.authorized_subnet_ids
  ip_restriction_headers                  = var.ip_restriction_headers
  function_app_vnet_integration_subnet_id = var.function_app_vnet_integration_subnet_id
  function_app_vnet_image_pull_enabled    = var.function_app_vnet_image_pull_enabled
  function_app_pe_subnet_id               = var.function_app_pe_subnet_id

  storage_account_network_rules_enabled = var.storage_account_network_rules_enabled
  storage_account_network_bypass        = var.storage_account_network_bypass
  storage_account_authorized_ips        = var.storage_account_authorized_ips

  scm_authorized_ips          = local.scm_authorized_ips
  scm_authorized_subnet_ids   = var.scm_authorized_subnet_ids
  scm_authorized_service_tags = var.scm_authorized_service_tags
  scm_ip_restriction_headers  = var.scm_ip_restriction_headers

  https_only                 = var.https_only
  builtin_logging_enabled    = var.builtin_logging_enabled
  client_certificate_enabled = var.client_certificate_enabled
  client_certificate_mode    = var.client_certificate_mode

  application_zip_package_path = var.application_zip_package_path

  staging_slot_enabled                     = var.staging_slot_enabled
  staging_slot_custom_name                 = var.staging_slot_custom_name
  staging_slot_custom_application_settings = var.staging_slot_custom_application_settings

  default_tags_enabled = var.default_tags_enabled

  extra_tags = merge(var.extra_tags, local.default_tags)
  application_insights_extra_tags = merge(
    var.extra_tags,
    var.application_insights_extra_tags,
    local.default_tags,
  )
  storage_account_extra_tags = merge(
    var.extra_tags,
    var.storage_account_extra_tags,
    local.default_tags,
  )
  function_app_extra_tags = merge(
    var.extra_tags,
    var.function_app_extra_tags,
    local.default_tags,
  )
}

module "windows_function" {
  for_each = toset(lower(var.os_type) == "windows" ? ["enabled"] : [])

  providers = {
    azurerm = azurerm
  }

  source = "./modules/windows-function"

  workload            = var.workload
  resource_group_name = var.resource_group_name
  location            = var.location
  location_short      = var.location_short

  use_caf_naming = var.use_caf_naming
  name_prefix    = var.name_prefix
  name_suffix    = var.name_suffix

  storage_uses_managed_identity  = var.storage_uses_managed_identity
  function_app_key_vault_id      = var.function_app_key_vault_id
  skip_identity_role_assignments = var.skip_identity_role_assignments

  storage_account_name_prefix                       = var.storage_account_name_prefix
  storage_account_custom_name                       = var.storage_account_custom_name
  use_existing_storage_account                      = var.use_existing_storage_account
  storage_account_id                                = var.storage_account_id
  storage_account_enable_advanced_threat_protection = var.storage_account_enable_advanced_threat_protection
  storage_account_enable_https_traffic_only         = var.storage_account_enable_https_traffic_only
  storage_account_kind                              = var.storage_account_kind
  storage_account_min_tls_version                   = var.storage_account_min_tls_version
  storage_account_identity_type                     = var.storage_account_identity_type
  storage_account_identity_ids                      = var.storage_account_identity_ids
  storage_subnet_id                                 = var.storage_subnet_id
  storage_account_is_hns_enabled                    = var.storage_account_is_hns_enabled
  storage_private_endpoints                         = var.storage_private_endpoints
  storage_ip_rules                                  = var.storage_ip_rules

  service_plan_id = local.service_plan_id

  function_app_name_prefix                       = var.function_app_name_prefix
  function_app_custom_name                       = var.function_app_custom_name
  function_app_application_settings              = var.function_app_application_settings
  function_app_application_settings_drift_ignore = var.function_app_application_settings_drift_ignore
  function_app_version                           = var.function_app_version
  site_config                                    = var.function_app_site_config
  sticky_settings                                = var.function_app_sticky_settings
  function_app_public_network_access_enabled     = local.function_app_public_network_access_enabled
  unique                                         = var.unique

  application_insights_name_prefix                           = var.application_insights_name_prefix
  application_insights_enabled                               = var.application_insights_enabled
  application_insights_id                                    = var.application_insights_id
  application_insights_type                                  = var.application_insights_type
  application_insights_custom_name                           = var.application_insights_custom_name
  application_insights_daily_data_cap                        = var.application_insights_daily_data_cap
  application_insights_daily_data_cap_notifications_disabled = var.application_insights_daily_data_cap_notifications_disabled
  application_insights_sampling_percentage                   = var.application_insights_sampling_percentage
  application_insights_retention                             = var.application_insights_retention
  application_insights_internet_ingestion_enabled            = var.application_insights_internet_ingestion_enabled
  application_insights_internet_query_enabled                = var.application_insights_internet_query_enabled
  application_insights_ip_masking_disabled                   = var.application_insights_ip_masking_disabled
  application_insights_local_authentication_disabled         = var.application_insights_local_authentication_disabled
  application_insights_force_customer_storage_for_profiler   = var.application_insights_force_customer_storage_for_profiler
  application_insights_log_analytics_workspace_id            = var.application_insights_log_analytics_workspace_id

  identity_type = var.identity_type
  identity_ids  = var.identity_ids

  logs_destinations_ids   = var.logs_destinations_ids
  logs_categories         = var.logs_categories
  logs_metrics_categories = var.logs_metrics_categories

  authorized_ips                          = local.authorized_ips
  authorized_service_tags                 = var.authorized_service_tags
  authorized_subnet_ids                   = var.authorized_subnet_ids
  ip_restriction_headers                  = var.ip_restriction_headers
  function_app_vnet_integration_subnet_id = var.function_app_vnet_integration_subnet_id
  function_app_vnet_image_pull_enabled    = var.function_app_vnet_image_pull_enabled
  function_app_pe_subnet_id               = var.function_app_pe_subnet_id
  storage_account_network_rules_enabled   = var.storage_account_network_rules_enabled
  storage_account_network_bypass          = var.storage_account_network_bypass
  storage_account_authorized_ips          = var.storage_account_authorized_ips

  scm_authorized_ips          = local.scm_authorized_ips
  scm_authorized_subnet_ids   = var.scm_authorized_subnet_ids
  scm_authorized_service_tags = var.scm_authorized_service_tags
  scm_ip_restriction_headers  = var.scm_ip_restriction_headers

  https_only                 = var.https_only
  builtin_logging_enabled    = var.builtin_logging_enabled
  client_certificate_enabled = var.client_certificate_enabled
  client_certificate_mode    = var.client_certificate_mode

  application_zip_package_path = var.application_zip_package_path

  staging_slot_enabled                     = var.staging_slot_enabled
  staging_slot_custom_name                 = var.staging_slot_custom_name
  staging_slot_custom_application_settings = var.staging_slot_custom_application_settings

  default_tags_enabled = var.default_tags_enabled

  extra_tags = merge(var.extra_tags, local.default_tags)
  application_insights_extra_tags = merge(
    var.extra_tags,
    var.application_insights_extra_tags,
    local.default_tags,
  )
  storage_account_extra_tags = merge(
    var.extra_tags,
    var.storage_account_extra_tags,
    local.default_tags,
  )
  function_app_extra_tags = merge(
    var.extra_tags,
    var.function_app_extra_tags,
    local.default_tags,
  )
}
