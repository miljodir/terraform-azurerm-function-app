resource "azurerm_private_endpoint" "main_pe" {
  count               = var.function_app_pe_subnet_id != null ? 1 : 0
  location            = azurerm_windows_function_app.windows_function.location
  name                = "${azurerm_windows_function_app.windows_function.name}-pe"
  resource_group_name = var.resource_group_name
  subnet_id           = var.function_app_pe_subnet_id

  private_service_connection {
    name                           = azurerm_windows_function_app.windows_function.name
    private_connection_resource_id = azurerm_windows_function_app.windows_function.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  lifecycle {
    # Avoid recreation of the private endpoint due to moving to central module
    ignore_changes = [
      private_service_connection[0].name,
      private_dns_zone_group,
    ]
  }
}

removed {
  from = azurerm_private_dns_a_record.main
  lifecycle {
    destroy = false
  }
}

removed {
  from = azurerm_private_dns_a_record.main_scm
  lifecycle {
    destroy = false
  }
}
