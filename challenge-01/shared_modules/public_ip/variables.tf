variable "public_ip" {
  type = object({
    name                = string
    resource_group_name = string
    location            = string
    allocation_method   = string
    sku                 = string
    domain_name         = string
    tags                = map(any)
  })
}