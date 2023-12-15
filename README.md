# Azure Function App

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](https://github.com/miljodir/terraform-azurerm-function-app/wiki/main#changelog)
[![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/miljodir/function-app/azurerm/)

This repo is forked from claranet/terraform-azurerm-function-app and modified towards meeting Miljødirektoratet's needs.
Main differences per December 2023 are support for private endpoints / non-public network access and removing diagnostic settings which are set up by other means.

This Terraform module creates an [Azure Function App](https://docs.microsoft.com/en-us/azure/azure-functions/)
with its [App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans),
a B1 Linux plan by default.
A [Storage Account](https://docs.microsoft.com/en-us/azure/storage/) and an [Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
are required and are created if not provided.
This module allows to deploy a application from a local or remote ZIP file that will be stored on the associated storage
account.

You can create an Azure Function with a pre-existing plan by referencing

 - `source = "miljodir/function-app/azurerm//modules/linux-function"`
 - `source = "miljodir/function-app/azurerm//modules/windows-function"`
