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

  timeout          = 1200 # Tăng hẳn lên 20 phút cho chắc ăn
  wait             = true
  force_update    = true
  recreate_pods   = true
  cleanup_on_fail  = true # Nếu lỗi thì xóa làm lại sạch sẽ
}

# Đợi ArgoCD ổn định một chút rồi mới tạo Root App
resource "time_sleep" "wait_for_argocd" {
  depends_on = [helm_release.argocd]
  create_duration = "30s"
}

resource "kubernetes_manifest" "root_app" {
  depends_on = [time_sleep.wait_for_argocd]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "root-app"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/hgiang25/k8s-gitops.git"
        targetRevision = "main"
        path           = "argocd"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }
}