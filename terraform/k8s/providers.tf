terraform {
  required_version = ">= 1.2.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.22.0"
    }
    azuread = {
      version = ">= 2.28.1"
    }
    kubernetes = {
      version = ">= 2.13.1"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)

  # using kubelogin to get an AAD token for the cluster.
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--environment",
      "AzurePublicCloud",
      "--server-id",
      data.azuread_service_principal.aks_aad_server.application_id, # Note: The AAD server app ID of AKS Managed AAD is always 6dae42f8-4368-4678-94ff-3960e28e3630 in any environments.
      "--client-id",
      azuread_application.app.application_id, # SPN App Id created via terraform
      "--client-secret",
      azuread_service_principal_password.spn_password.value,
      "--tenant-id",
      data.azurerm_subscription.current.tenant_id, # AAD Tenant Id
      "--login",
      "spn"
    ]
  }
}