resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"

  create_namespace = true

  values = [file("${path.module}/values.yaml")]

  # Thêm dòng này để chắc chắn namespace tạo xong mới chạy Helm
  depends_on = [kubernetes_namespace_v1.argocd]
}