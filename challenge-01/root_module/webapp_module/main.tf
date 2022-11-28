module "linux_app_service" {
  source               = "../../shared_module/app_service"
  linux_webapp_service = var.linux_webapp_service
}