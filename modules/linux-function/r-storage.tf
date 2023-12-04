module "storage" {
  for_each = toset(var.use_existing_storage_account ? [] : ["enabled"])

  source  = "miljodir/storage-account/azurerm"
  version = ">= 1.0, <= 2.0"

  providers = {
    azurerm       = azurerm
    azurerm.p-dns = azurerm.p-dns
  }

  resource_group_name                  = azurerm_resource_group.rg_web.name
  storage_account_name                 = "${replace(azurerm_resource_group.rg_web.name, "-", "")}${random_string.unique.result}"
  account_kind                         = "StorageV2"
  blob_soft_delete_retention_days      = 7
  container_soft_delete_retention_days = 7
  is_hns_enabled                       = false
  min_tls_version                      = "TLS1_2"
  shared_access_key_enabled            = false
  sku_name                             = "Standard_LRS"
  subnet_id                            = module.vnet.subnets["privatelink"].id
  public_network_access_enabled        = false
  allow_nested_items_to_be_public      = false

  private_endpoints = [
    "blob",
  ]
  network_rules = {
    default_action = "Deny"
    bypass         = ["None"]
    subnet_ids     = []
  }
}

resource "azurerm_storage_account_network_rules" "storage_network_rules" {
  for_each = toset(!var.use_existing_storage_account && var.storage_account_network_rules_enabled ? ["enabled"] : [])

  storage_account_id = local.storage_account_output.id

  default_action             = "Deny"
  ip_rules                   = local.storage_ips
  virtual_network_subnet_ids = distinct(compact(concat(var.authorized_subnet_ids, [var.function_app_vnet_integration_subnet_id])))
  bypass                     = var.storage_account_network_bypass

  lifecycle {
    precondition {
      condition     = var.function_app_vnet_integration_subnet_id != null
      error_message = "Network rules on Storage Account cannot be set for same region Storage without VNet integration."
    }
  }
}

data "azurerm_storage_account" "storage" {
  name                = var.use_existing_storage_account ? split("/", var.storage_account_id)[8] : module.storage["enabled"].storage_account_name
  resource_group_name = var.use_existing_storage_account ? split("/", var.storage_account_id)[4] : var.resource_group_name

  depends_on = [module.storage]
}

resource "azurerm_storage_container" "package_container" {
  count = var.application_zip_package_path != null && local.is_local_zip ? 1 : 0

  name                  = "functions-packages"
  storage_account_name  = data.azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "package_blob" {
  count = var.application_zip_package_path != null && local.is_local_zip ? 1 : 0

  name                   = "${local.function_app_name}.zip"
  storage_account_name   = azurerm_storage_container.package_container[0].storage_account_name
  storage_container_name = azurerm_storage_container.package_container[0].name
  type                   = "Block"
  source                 = var.application_zip_package_path
  content_md5            = filemd5(var.application_zip_package_path)
}

data "azurerm_storage_account_sas" "package_sas" {
  for_each = toset(var.application_zip_package_path != null && !var.storage_uses_managed_identity ? ["enabled"] : [])

  connection_string = data.azurerm_storage_account.storage.primary_connection_string
  https_only        = false
  resource_types {
    service   = false
    container = false
    object    = true
  }
  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }
  start  = "2021-01-01"
  expiry = "2041-01-01"
  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    filter  = false
    tag     = false
  }
}
