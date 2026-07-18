resource "kubernetes_deployment" "profileforge_celery_beat" {
  metadata {
    name      = "profileforge-celery-beat"
    namespace = kubernetes_namespace.profileforge_dev.metadata[0].name

    labels = {
      app = "profileforge-celery-beat"
    }
  }

  wait_for_rollout = true

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "profileforge-celery-beat"
      }
    }

    template {
      metadata {
        labels = {
          app = "profileforge-celery-beat"
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
          name              = "celery-beat"
          image             = "profileforge-backend:local"
          image_pull_policy = "IfNotPresent"

          command = [
            "celery"
          ]

          args = [
            "-A",
            "config.celery_app",
            "beat",
            "-l",
            "info",
            "--schedule=/data/celerybeat/celerybeat-schedule"
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
              cpu    = "50m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }

          volume_mount {
            name       = "celerybeat-storage"
            mount_path = "/data/celerybeat"
          }
        }

        volume {
          name = "celerybeat-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.celerybeat_pvc.metadata[0].name
          }
        }
      }
    }
  }
}
