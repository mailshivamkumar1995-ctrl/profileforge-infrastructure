resource "kubernetes_manifest" "profileforge_backend_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"

    metadata = {
      name      = "profileforge-backend"
      namespace = "monitoring"

      labels = {
        release = "monitoring"
      }
    }

    spec = {
      selector = {
        matchLabels = {
          app = "profileforge-backend"
        }
      }

      namespaceSelector = {
        matchNames = [
          kubernetes_namespace.profileforge_dev.metadata[0].name
        ]
      }

      endpoints = [
        {
          port     = "http"
          path     = "/metrics"
          interval = "30s"
        }
      ]
    }
  }

  depends_on = [
    kubernetes_service.profileforge_backend
  ]
}
