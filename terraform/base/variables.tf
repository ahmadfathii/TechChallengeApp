variable "prefix" {
  type        = string
  description = "This variable defines the prefix used to build resources"
  default     = "servian"
}

variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
}

variable "location" {
  type        = string
  description = "Resources location in Azure"
}

variable "cluster_name" {
  type        = string
  description = "AKS name in Azure"
}

variable "acr_name" {
  type        = string
  description = "ACR name in Azure"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}

variable "system_node_count" {
  type        = number
  description = "Number of AKS worker nodes"
}

variable "spn_name" {
  type        = string
  description = "Name of Service Principal"
}

variable "kube_namespace" {
  type        = string
  description = "Name of Kubernetes Namespace"
}

variable "aad_group_aks_admins" {
  type        = string
  description = "Name of AAD group for AKS admins"
}

variable "aad_app" {
  type        = string
  description = "Name of AAD application for AKS admins"
}

variable "postgresql_admin_login" {
  type        = string
  description = "Login to authenticate to PostgreSQL Server"
}
variable "postgresql_admin_password" {
  type        = string
  description = "Password to authenticate to PostgreSQL Server"
}
variable "postgresql_version" {
  type        = string
  description = "PostgreSQL Server version to deploy"
  default     = "10.7"
}
variable "postgresql_sku_name" {
  type        = string
  description = "PostgreSQL SKU Name"
  default     = "B_Gen5_1"
}
variable "postgresql_storage" {
  type        = string
  description = "PostgreSQL Storage in MB"
  default     = "5120"
}
variable "postgresql_server_name" {
  type        = string
  description = "PostgreSQL server name"
  default     = "server_postgresql_servian"
}
variable "postgresql_db_name" {
  type        = string
  description = "PostgreSQL db name"
}

variable "resource_group_db_name" {
  type        = string
  description = "RG name in Azure"
}

variable "build_id" {
  type        = string
  description = "Build ID of Azure DevOps Pipeline"
}
