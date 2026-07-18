resource "kubernetes_namespace" "profileforge_dev" {
  metadata {
    name = "profileforge-dev"
  }
}
