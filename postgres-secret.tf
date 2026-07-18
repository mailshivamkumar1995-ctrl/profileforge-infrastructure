resource "kubernetes_secret" "postgres_secret" {
  metadata {
    name      = "postgres-secret"
    namespace = kubernetes_namespace.profileforge_dev.metadata[0].name
  }

  type = "Opaque"

  data = {
    password = "REDACTED"
  }
}
