data "azurerm_subnet" "subnet" {
  name                 = var.private_endpoint.subnet.name
  virtual_network_name = var.private_endpoint.subnet.virtual_network_name
  resource_group_name  = var.private_endpoint.subnet.resource_group_name
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.private_endpoint.name
  location            = var.private_endpoint.location
  resource_group_name = var.private_endpoint.resource_group_name
  subnet_id           = data.azurerm_subnet.subnet.id


  private_service_connection {
    name                           = var.private_endpoint.private_service_connection.name
    private_connection_resource_id = var.private_endpoint.private_service_connection.private_connection_resource_id
    is_manual_connection           = var.private_endpoint.private_service_connection.is_manual_connection
    subresource_names              = var.private_endpoint.private_service_connection.subresource_names
  }

  private_dns_zone_group {
    name                 = var.private_endpoint.private_dns_zone_group.name
    private_dns_zone_ids = var.private_endpoint.private_dns_zone_group.private_dns_zone_ids
  }
  tags = var.private_endpoint.tags
}