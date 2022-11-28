variable "virtual_network" {
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    address_space       = string
    tags                = string
  })
}