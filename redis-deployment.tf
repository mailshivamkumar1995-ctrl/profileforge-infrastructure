resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.profileforge_dev.metadata[0].name

    labels = {
      app = "redis"
    }
  }

  wait_for_rollout = true

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false

        container {
          name  = "redis"
          image = "redis:7-alpine"

          args = [
            "redis-server",
            "--appendonly",
            "yes"
          ]

          port {
            container_port = 6379
          }

          volume_mount {
            name       = "redis-storage"
            mount_path = "/data"
          }
        }

        volume {
          name = "redis-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.redis_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.profileforge_dev.metadata[0].name
  }

  wait_for_load_balancer = false

  spec {
    selector = {
      app = "redis"
    }

    port {
      protocol    = "TCP"
      port        = 6379
      target_port = 6379
    }

    type = "ClusterIP"
  }
}
