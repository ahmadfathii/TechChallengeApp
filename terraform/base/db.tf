resource "azurerm_resource_group" "postgresql-rg" {
  name     = var.resource_group_db_name
  location = var.location
}
resource "azurerm_postgresql_server" "postgresql-server" {
  name                = var.postgresql_server_name
  location            = azurerm_resource_group.postgresql-rg.location
  resource_group_name = azurerm_resource_group.postgresql-rg.name
 
  administrator_login          = var.postgresql_admin_login
  administrator_login_password = var.postgresql_admin_password
 
  sku_name          = var.postgresql_sku_name
  version           = var.postgresql_version
  storage_mb        = var.postgresql_storage
  auto_grow_enabled = true
  
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
  ssl_minimal_tls_version_enforced  = "TLSEnforcementDisabled"
}

resource "azurerm_postgresql_database" "postgresql-db" {
  name                = var.postgresql_db_name
  resource_group_name = azurerm_resource_group.postgresql-rg.name
  server_name         = azurerm_postgresql_server.postgresql-server.name
  charset             = "utf8"
  collation           = "en_US"
}

resource "azurerm_postgresql_firewall_rule" "postgresql_firewall_rule" {
  name                = "challengeapp_rule"
  resource_group_name = azurerm_resource_group.postgresql-rg.name
  server_name         = azurerm_postgresql_server.postgresql-server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}