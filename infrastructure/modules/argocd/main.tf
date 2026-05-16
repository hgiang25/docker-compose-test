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
  wait            = true
  force_update    = true
  recreate_pods   = true
  cleanup_on_fail = true
}

# Giữ lại phần Wait cho ArgoCD Server Ready
resource "time_sleep" "wait_argocd" {
  depends_on = [
    helm_release.argocd
  ]

  create_duration = "180s"
}

resource "time_sleep" "wait_alb_controller" {
  depends_on = [
    helm_release.argocd
  ]

  create_duration = "180s"
}