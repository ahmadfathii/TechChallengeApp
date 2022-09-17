# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1
resource "kubernetes_deployment_v1" "deploy-servian" {
  metadata {
    name      = "deploy-servian"
    namespace = kubernetes_namespace_v1.ns.metadata.0.name

    labels = {
      tier = "servian"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        tier = "servian"
      }
    }

    template {
      metadata {
        labels = {
          tier = "servian"
        }
      }

      spec {
        container {
          image = "${data.azurerm_container_registry.acr.login_server}/${var.repository}:${var.build_id}"
          name  = "servian"
          env {
            name  = "VTT_DBUSER"
            value = format("'%s@%s'", var.postgresql_admin_login , var.postgresql_server_name)
          }
          env {  
            name  = "VTT_DBPASSWORD" 
            value = var.postgresql_admin_password
          }
          env {
            name  = "VTT_DBNAME"
            value = var.postgresql_db_name
          }
          env {
            name  = "VTT_HOST"
            value = data.azurerm_postgresql_server.postgresql-server.fqdn
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          
        }
      }
    }
  }
}
