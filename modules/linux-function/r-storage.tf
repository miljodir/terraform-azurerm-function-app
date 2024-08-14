locals {
  storage_default_private_endpoints = var.storage_subnet_id != null ? ["blob", ] : []
}

module "storage" {
  for_each = toset(var.use_existing_storage_account ? [] : ["enabled"])

  source  = "miljodir/storage-account/azurerm"
  version = "~> 1.0"

  providers = {
    azurerm       = azurerm
    azurerm.p-dns = azurerm.p-dns
  }

  resource_group_name  = var.resource_group_name
  storage_account_name = local.storage_account_name

  account_kind                         = "StorageV2"
  blob_soft_delete_retention_days      = 7
  container_soft_delete_retention_days = 7
  is_hns_enabled                       = var.storage_account_is_hns_enabled
  min_tls_version                      = "TLS1_2"
  shared_access_key_enabled            = var.storage_uses_managed_identity == false ? true : false
  sku_name                             = "Standard_LRS"
  subnet_id                            = var.storage_subnet_id != null ? var.storage_subnet_id : null
  public_network_access_enabled        = var.storage_subnet_id != null && length(var.storage_ip_rules) == 0 ? false : true
  allow_nested_items_to_be_public      = false

  private_endpoints = concat(local.storage_default_private_endpoints, var.storage_private_endpoints)
  network_rules = {
    default_action = var.storage_subnet_id != null ? "Deny" : "Allow"
    bypass         = ["None"]
    subnet_ids     = []
    ip_rules       = var.storage_ip_rules
  }
}

resource "azurerm_role_assignment" "functionapp_storage_dataowner" {
  count                = var.storage_uses_managed_identity && var.skip_identity_role_assignments == false ? 1 : 0
  role_definition_name = "Storage Blob Data Owner"
  scope                = data.azurerm_storage_account.storage.id
  principal_id         = azurerm_linux_function_app.linux_function.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "functionapp_slot_storage_dataowner" {
  count                = var.staging_slot_enabled && var.storage_uses_managed_identity && var.skip_identity_role_assignments == false ? 1 : 0
  scope                = var.function_app_key_vault_id
  principal_id         = azurerm_linux_function_app_slot.linux_function_slot[0].identity[0].principal_id
  role_definition_name = "Storage Blob Data Owner"
  principal_type       = "ServicePrincipal"
}


data "azurerm_storage_account" "storage" {
  name                = var.use_existing_storage_account ? split("/", var.storage_account_id)[8] : module.storage["enabled"].storage_account.name
  resource_group_name = var.use_existing_storage_account ? split("/", var.storage_account_id)[4] : var.resource_group_name
}
