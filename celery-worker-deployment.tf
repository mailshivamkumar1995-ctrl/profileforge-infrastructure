resource "kubernetes_deployment" "profileforge_celery_worker" {
  metadata {
    name      = "profileforge-celery-worker"
    namespace = kubernetes_namespace.profileforge_dev.metadata[0].name

    labels = {
      app = "profileforge-celery-worker"
    }
  }

  wait_for_rollout = true

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "profileforge-celery-worker"
      }
    }

    template {
      metadata {
        labels = {
          app = "profileforge-celery-worker"
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
          name              = "celery-worker"
          image             = "profileforge-backend:local"
          image_pull_policy = "IfNotPresent"

          command = [
            "celery"
          ]

          args = [
            "-A",
            "config.celery_app",
            "worker",
            "-l",
            "info",
            "--concurrency=2"
          ]

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

          liveness_probe {
            exec {
              command = [
                "sh",
                "-c",
                "celery -A config.celery_app inspect ping -d celery@$HOSTNAME"
              ]
            }

            initial_delay_seconds = 60
            period_seconds        = 30
            timeout_seconds       = 10
            failure_threshold     = 3
          }

          readiness_probe {
            exec {
              command = [
                "sh",
                "-c",
                "celery -A config.celery_app inspect ping -d celery@$HOSTNAME"
              ]
            }

            initial_delay_seconds = 30
            period_seconds        = 15
            timeout_seconds       = 10
            failure_threshold     = 3
          }
        }
      }
    }
  }
}
