resource "kubernetes_secret" "django_secret" {
  metadata {
    name      = "django-secret"
    namespace = kubernetes_namespace.profileforge_dev.metadata[0].name
  }
  type = "Opaque"
  data = {
    secret-key = "WctIMavepYT3--kihcJ8_xJNDuiR56k-QNf4vrAYslZuesyrwxDdt3ksOU-m1pU3ayOs6R8Qg3HbUm-HOnlEnQ"
  }
}
