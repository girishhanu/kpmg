
resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip.name
  resource_group_name = var.public_ip.resource_group_name
  location            = var.public_ip.location
  allocation_method   = var.public_ip.allocation_method
  sku                 = var.public_ip.sku
  domain_name_label   = var.public_ip.domain_name
  tags                = var.public_ip.tags
}