variable "application_gateway" {
  type = object({
    name                = string
    resource_group_name = string
    location            = string
    domain_name         = string
    public_ip_name      = string
    sku = object({
      name      = string
      tier      = string
      autoscale = string
    })
    subnet = object({
      name                 = string
      resource_group_name  = string
      virtual_network_name = string
    })
    key_vault = object({
      name                = string
      resource_group_name = string
    })
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