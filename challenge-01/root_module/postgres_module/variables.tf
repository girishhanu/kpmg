variable "postgres_server" {
  type = object({
    name                             = string
    location                         = string
    resource_group_name              = string
    admin_username                   = string
    admin_password                   = string
    sku_name                         = string
    version                          = string
    storage_mb                       = string
    backup_retention_days            = string
    geo_redundant_backup_enabled     = bool
    auto_grow_enabled                = bool
    public_network_access_enabled    = bool
    ssl_enforcement_enabled          = bool
    ssl_minimal_tls_version_enforced = bool
  })
  tags           = map(any)
  configurations = map(any)
}