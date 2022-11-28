variable "linux_webapp_service" {
  type = object({
    service_plan = object({
      name                = string
      resource_group_name = string
    })
    subnet = object({
      name                 = string
      resource_group_name  = string
      virtual_network_name = string
    })
    managed_identity = object({
      name                = string
      resource_group_name = string
    })
    application_insights = object({
      name                = string
      resource_group_name = string
    })
    site_config = object({
      always_on                                     = bool
      container_registry_managed_identity_client_id = bool
      ftps_state                                    = string
      minimum_tls_version                           = string
      vnet_route_all_enabled                        = bool
    })
  })
}