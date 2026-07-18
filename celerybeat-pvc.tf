resource "kubernetes_persistent_volume_claim" "celerybeat_pvc" {
  metadata {
    name      = "celerybeat-pvc"
    namespace = kubernetes_namespace.profileforge_dev.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}
