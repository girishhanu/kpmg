locals {
  web_app_default_config = {
    https_only = true
    identity = {
      type = "UserAssigned"
    }
  }
}

data "azurerm_application_insights" "application_insights" {
  name                = var.linux_webapp_service.application_insights.name
  resource_group_name = var.linux_webapp_service.application_insights.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.linux_webapp_service.subnet.name
  resource_group_name  = var.linux_webapp_service.subnet.resource_group_name
  virtual_network_name = var.linux_webapp_service.subnet.virtual_network_name
}

data "azurerm_service_plan" "service_plan" {
  name                = var.linux_webapp_service.service_plan.plan_name
  resource_group_name = var.linux_webapp_service.service_plan.resource_group_name
}

data "azurerm_user_assigned_identity" "user_managed_identity" {
  name                = var.linux_webapp_service.managed_identity.name
  resource_group_name = var.linux_webapp_service.managed_identity.resource_group_name
}

resource "azurerm_linux_web_app" "linux_web_app" {
  name                = var.linux_webapp_service.name
  resource_group_name = var.linux_webapp_service.resource_group_name
  location            = var.linux_webapp_service.location
  service_plan_id     = data.azurerm_service_plan.service_plan.id

  identity {
    type         = local.web_app_default_config.identity.type
    identity_ids = [data.azurerm_user_assigned_identity.user_managed_identity.id]
  }
  site_config {
    always_on                                     = var.linux_webapp_service.site_config.always_on
    container_registry_managed_identity_client_id = var.linux_webapp_service.site_config.container_registry_managed_identity_client_id
    container_registry_use_managed_identity       = data.azurerm_user_assigned_identity.user_managed_identity.id
    ftps_state                                    = var.linux_webapp_service.site_config.ftps_state
    minimum_tls_version                           = var.linux_webapp_service.site_config.minimum_tls_version
    vnet_route_all_enabled                        = var.linux_webapp_service.site_config.vnet_route_all_enabled
  }
  tags = var.linux_webapp_service.tags
}