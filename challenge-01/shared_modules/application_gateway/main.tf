data "azurerm_subnet" "subnet" {
  name                 = var.application_gateway.subnet.name
  resource_group_name  = var.application_gateway.subnet.resource_group_name
  virtual_network_name = var.application_gateway.subnet.virtual_network_name
}

data "azurerm_user_assigned_identity" "user_managed_identity" {
  name                = var.application_gateway.managed_identity.name
  resource_group_name = var.application_gateway.managed_identity.resource_group_name
}

data "azurerm_key_vault" "key_vault" {
  name                = var.application_gateway.key_vault.name
  resource_group_name = var.application_gateway.key_vault.resource_group_name
}

data "azurerm_key_vault_secret" "key_secrets" {
  for_each     = var.application_list
  name         = each.value.front_end_configuration.ssl_cert
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_web_application_firewall_policy" "firewall_policy" {
  name                = var.application_gateway.firewall_policy.name
  resource_group_name = var.application_gateway.firewall_policy.resource_group_name
}

module "application_gateway_public_ip" {
  source    = "../../shared_madules/public_ip"
  public_ip = local.application_gateway_public_ip_config
}


resource "azurerm_application_gateway" "application_gateway" {
  name                = var.application_gateway.name
  resource_group_name = var.application_gateway.resource_group_name
  location            = var.application_gateway.location

  sku {
    name     = var.application_gateway.sku.name
    tier     = var.application_gateway.sku.tier
    capacity = var.application_gateway.sku.autoscale
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = data.azurerm_subnet.subnet.id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = module.application_gateway_public_ip.public_ip_id
  }

  dynamic "frontend_port" {
    for_each = local.frontend_ports
    content {
      name = "front_end_port-${frontend_port.value}"
      port = frontend_port.value
    }
  }

  dynamic "http_listener" {
    for_each = var.application_list
    content {
      name                           = "agw_listener-${http_listener.key}-${local.http_port}"
      frontend_ip_configuration_name = local.frontend_ip_configuration_name
      frontend_port_name             = "agw_port-${local_http_port}"
      protocol                       = "Http"
      host_name                      = http_listener.value.front_end_configuration_host_name
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.application_list
    content {
      name                = "ssl_cert-${ssl_certificate.key}"
      key_vault_secret_id = data.azurerm_key_vault_secret.key_secrets["${ssl_certificate.key}"].id
    }
  }

  dynamic "http_listener" {
    for_each = var.application_list
    content {
      name                           = "agw_listener-${http_listener.key}-${local.https_port}"
      frontend_ip_configuration_name = local.frontend_ip_configuration_name
      frontend_port_name             = "agw_port-${local_https_port}"
      protocol                       = "Https"
      host_name                      = http_listener.value.front_end_configuration.host_name
      ssl_certificate_name           = "ssl_cert-${http_listener.key}"
    }
  }

  dynamic "probe" {
    for_each = var.application_list
    content {
      name                = "agw-probe-${probe.key}"
      protocal            = probe.value.probe_configuration.protocal
      path                = probe.value.probe_configuration.path
      timeout             = probe.value.probe_configuration.timeout
      interval            = probe.value.probe_configuration.interval
      unhealthy_threshold = probe.value.probe_configuration.threshould
      host                = probe.value.probe.front_end_configuration.host_name
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.application_list
    content {
      name                  = "http-settings-${backend_http_settings.key}"
      cookie_based_affinity = backend_http_settings.value.backend_configuration.affinity
      path                  = backend_http_settings.value.backend_configuration.path
      port                  = local.https_port
      protocol              = "Https"
      request_timeout       = backend_http_settings.value.backend_configuration.time_out
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.application_list
    content {
      name  = "address_pool-${backend_address_pool.key}"
      fqdns = backend_address_pool.value.backend_configuration.fqdns
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.application_list
    content {
      name                       = "routing_rule-${request_routing_rule.key}-${local.https_port}"
      rule_type                  = "Basic"
      http_listener_name         = "agw_listener-${http_listener.key}-${local.https_port}"
      backend_address_pool_name  = "address_pool-${backend_address_pool.key}"
      backend_http_settings_name = "http-settings-${backend_http_settings.key}"
      priority                   = request_routing_rule.value.backend_configuration.priority
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.application_list
    content {
      name                 = "redirect-config-${redirect_configuration.key}"
      redirect_type        = "Permanent"
      target_listener_name = "agw_listener-${http_listener.key}-${local.https_port}"
      include_path         = true
      include_query_string = true
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.application_list
    content {
      name                        = "routing_rule-${request_routing_rule.key}-${local.http_port}"
      rule_type                   = "Basic"
      http_listener_name          = "agw_listener-${http_listener.key}-${local.http_port}"
      redirect_configuration_name = "redirect-config-${redirect_configuration.key}"
      priority                    = sum([100, request_routing_rule.value.backend_configuration.priority])
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.user_managed_identity.id]
  }
  tags       = var.aplication_gateway.tags
  depends_on = [module.application_gateway_public_ip]
}