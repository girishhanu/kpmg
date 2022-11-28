resource "azurerm_virtual_network" "virtual_network" {
  name                = var.virtual_network.name
  location            = var.virtual_network.location
  resource_group_name = var.virtual_network.resource_group_name
  address_space       = var.virtual_network.address_space
  tags                = var.virtual_network.tags
}