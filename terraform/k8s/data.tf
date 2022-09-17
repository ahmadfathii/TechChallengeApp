# current subscription
data "azurerm_subscription" "current" {}

# current client
data "azuread_client_config" "current" {}

# retrieve the versions of Kubernetes supported by AKS
data "azurerm_kubernetes_service_versions" "current" {
  location = var.location
}

data "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
}

data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_resource_group" "postgresql-rg" {
  name     = var.resource_group_db_name
}

data "azurerm_postgresql_server" "postgresql-server" {
  name                = var.postgresql_server_name
  resource_group_name = data.azurerm_resource_group.postgresql-rg.name
}



data "azurerm_kubernetes_cluster" "aks" {
  name                   = var.cluster_name
  resource_group_name    = data.azurerm_resource_group.rg.name
}

data "azuread_group" "aks_admins" {
  display_name     = var.aad_group_aks_admins
}

# reference to Azure Kubernetes Service AAD Server app in AAD
data "azuread_service_principal" "aks_aad_server" {
  display_name = "Azure Kubernetes Service AAD Server"
}