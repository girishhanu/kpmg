module "postgres_server" {
  source          = "../../shared_modules/postgresql_server"
  postgres_server = var.postgres_server
}