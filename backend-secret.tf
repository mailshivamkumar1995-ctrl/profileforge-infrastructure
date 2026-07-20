resource "kubernetes_secret" "backend_secret" {
  metadata {
    name      = "backend-secret"
    namespace = kubernetes_namespace.profileforge_dev.metadata[0].name
  }

  type = "Opaque"

  data = {
    database-url = var.backend_database_url
  }
}
