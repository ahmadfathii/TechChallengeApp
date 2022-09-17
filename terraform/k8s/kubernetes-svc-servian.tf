resource "kubernetes_service_v1" "svc" {
  metadata {
    name      = "servian-svc"
    namespace = kubernetes_namespace_v1.ns.metadata.0.name
  }
  spec {
    selector = {
      tier = kubernetes_deployment_v1.deploy-servian.spec.0.template.0.metadata.0.labels.tier
    }
    port {
      port        = 80
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}
