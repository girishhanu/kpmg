module "application_gateway" {
  source              = "../../shared_modules/application_gateway"
  application_gateway = var.application_gateway_config
  application_list    = var.application_list
}