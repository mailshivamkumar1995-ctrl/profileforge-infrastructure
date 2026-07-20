resource "kubernetes_secret" "django_secret" {
  metadata {
    name      = "django-secret"
    namespace = kubernetes_namespace.profileforge_dev.metadata[0].name
  }
  type = "Opaque"
  data = {
    secret-key = var.django_secret_key
  }
}
