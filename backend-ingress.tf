resource "kubernetes_ingress_v1" "profileforge_backend" {
  metadata {
    name      = "profileforge-backend"
    namespace = kubernetes_namespace.profileforge_dev.metadata[0].name
  }

  wait_for_load_balancer = false

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "profileforge.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.profileforge_backend.metadata[0].name

              port {
                number = 8000
              }
            }
          }
        }
      }
    }
  }
}
