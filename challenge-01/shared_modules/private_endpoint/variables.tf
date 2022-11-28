variable "private_endpoint" {
  type = object({
    name                = string
    resource_group_name = string
    location            = string

    subnet = object({
      name                 = string
      resource_group_name  = string
      virtual_network_name = string
    })

    private_service_connection = object({
      name                           = string
      subresource_names              = list(string)
      is_manual_connection           = bool
      private_connection_resource_id = string
    })

    private_dns_zone_group = object({
      name                 = string
      private_dns_zone_ids = list(string)
    })

    tags = map(any)
  })
}