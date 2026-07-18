resource "kubernetes_deployment" "profileforge_backend" {
  metadata {
    name      = "profileforge-backend"
    namespace = kubernetes_namespace.profileforge_dev.metadata[0].name

    labels = {
      app = "profileforge-backend"
    }
  }

  wait_for_rollout = true

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "profileforge-backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "profileforge-backend"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false

        security_context {
          run_as_non_root = true
          run_as_user     = 1000
          fs_group        = 1000
        }

        container {
          name              = "backend"
          image             = "profileforge-backend:local"
          image_pull_policy = "IfNotPresent"

          port {
            name           = "http"
            container_port = 8000
          }

          env {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "config.settings.production"
          }

          env {
            name  = "DEBUG"
            value = "False"
          }

          env {
            name = "SECRET_KEY"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.django_secret.metadata[0].name
                key  = "secret-key"
              }
            }
          }

          env {
            name  = "ALLOWED_HOSTS"
            value = "profileforge.local,localhost,127.0.0.1"
          }

          env {
            name = "DATABASE_URL"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.backend_secret.metadata[0].name
                key  = "database-url"
              }
            }
          }

          env {
            name  = "REDIS_URL"
            value = "redis://redis:6379"
          }

          liveness_probe {
            tcp_socket {
              port = 8000
            }

            initial_delay_seconds = 30
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            tcp_socket {
              port = 8000
            }

            initial_delay_seconds = 15
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }

            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "profileforge_backend" {
  metadata {
    name      = "profileforge-backend"
    namespace = kubernetes_namespace.profileforge_dev.metadata[0].name

    labels = {
      app = "profileforge-backend"
    }
  }

  wait_for_load_balancer = false

  spec {
    selector = {
      app = "profileforge-backend"
    }

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 8000
      target_port = 8000
    }

    type = "ClusterIP"
  }
}
