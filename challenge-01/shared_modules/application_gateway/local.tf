locals {
  gateway_ip_configuration_name  = "agw-ip-${application_gateway.name}"
  frontend_ip_configuration_name = "agw-fe-ip-${application_gateway.name}"
  http_port                      = 80
  https_port                     = 443
  application_gateway_public_ip_config = {
    name                = var.application_gateway.public_ip_name
    resource_group_name = var.application_gateway.resource_group_name
    location            = var.application_gateway.location
    allocation_mothod   = "Static"
    sku                 = "Standard"
    domain_name_label   = var.application_gateway.domain_name
    tags                = var.application_gateway.tags
  }
}