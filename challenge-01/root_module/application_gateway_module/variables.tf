variable "application_gateway" {
  type = object({
    name = string
    # Use shared resource group or create new resource group inside the module and refer the id
    resource_group_name = string
    location            = string
    domain_name         = string
    public_ip_name      = string
    sku = object({
      name      = string
      tier      = string
      autoscale = string
    })
    # Use shared virtual network or create new virtual network inside the module and refer the subnet and vnet names
    subnet = object({
      name                 = string
      resource_group_name  = string
      virtual_network_name = string
    })
    # Use shared key vault or create new key vault inside the module and refer the key vault
    key_vault = object({
      name                = string
      resource_group_name = string
    })
    # Use shared managed identity or create managed identity inside the module and refer identity id
    managed_identity = object({
      name                = string
      resource_group_name = string
    })
    tags = map(any)
  })
}

variable "application_list" {
  type = map(object({
    front_end_configuration = object({
      host_name = string
      ssl_cert  = string
    })
    backend_configuration = object({
      affinity = optional(string, "Enabled")
      path     = optional(string, "/")
      time_out = optional(number, 30)
      fqdns    = list(string)
    })
    probe_configuration = object({
      protocal   = optional(string, "Https")
      path       = optional(string, "/")
      timeout    = optional(number, 30)
      interval   = optional(number, 30)
      threshould = optional(number, 3)
    })
  }))
}