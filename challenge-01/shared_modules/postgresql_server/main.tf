
locals {

  private_end_point_configuration = {
    name                = "pe-psql-${var.postgres_server.name}"
    resource_group_name = var.postgres_server.resource_group_name
    location            = var.postgres_server.location

    dns = {
      name                = var.postgres_server.dns_zone.name
      resource_group_name = var.postgres_server.resource_group_name
    }

    private_dns_zone_group = {
      name                 = var.postgres_server.dns_zone.name
      private_dns_zone_ids = var.postgres_server.dns_zone.resource_id
    }
    private_service_connection = {
      name                           = "pe-psql-sc-${var.postgres_server.name}"
      subresource_names              = ["postgresqlServer"]
      is_manual_connection           = false
      private_connection_resource_id = azurerm_postgresql_server.postgres_server.id
    }
    subnet = {
      name                 = var.postgres_server.subnet.name
      resource_group_name  = var.postgres_server.subnet.resource_group_name
      virtual_network_name = var.postgres_server.subnet.virtual_network_name
    }
    tags = var.postgres_server.tags
  }
}

resource "azurerm_postgresql_server" "postgres_server" {
  name                = var.postgres_server.name
  location            = var.postgres_server.location
  resource_group_name = var.postgres_server.resource_group_name

  administrator_login          = var.postgres_server.admin_username
  administrator_login_password = var.postgres_server.admin_password

  sku_name   = var.postgres_server.sku_name
  version    = var.postgres_server.version
  storage_mb = var.postgres_server.storage_mb

  backup_retention_days        = var.postgres_server.backup_retention_days
  geo_redundant_backup_enabled = var.postgres_server.geo_redundant_backup_enabled
  auto_grow_enabled            = var.postgres_server.auto_grow_enabled

  public_network_access_enabled    = var.postgres_server.public_network_access_enabled
  ssl_enforcement_enabled          = var.postgres_server.ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced = var.postgres_server.ssl_minimal_tls_version_enforced
  identity {
    type = var.postgres_server.type
  }
  tags = var.postgres_server.tags
}

resource "azurerm_postgresql_configuration" "postgres_server" {
  count               = length(keys(var.postgres_server.configurations))
  name                = element(keys(var.postgres_server.configurations), count.index)
  resource_group_name = var.postgres_server.resource_group_name
  server_name         = azurerm_postgresql_server.postgres_server.name
  value               = element(values(var.postgres_server.configurations), count.index)
  depends_on = [
    azurerm_postgresql_server.postgres_server
  ]
}

module "private_end_point" {
  count            = var.postgres_server.enable_private_endpoint ? 1 : 0
  source           = "../../shared_modules/private_endpoint"
  private_endpoint = local.private_end_point_configuration
  depends_on = [
    azurerm_postgresql_configuration.postgres_server
  ]
}