variable "subnet" {
  type = object({
    name                 = string
    virtual_network_name = string
    resource_group_name  = string
    address_prefix       = string
  })
}