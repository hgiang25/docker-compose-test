# Giữ lại Namespace cho ArgoCD
resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Giữ lại Helm Release lõi của ArgoCD
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"

  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [
    kubernetes_namespace_v1.argocd
  ]

  timeout         = 1200
  wait            = false
  force_update    = true
  recreate_pods   = true
  cleanup_on_fail = false
  atomic = false
}