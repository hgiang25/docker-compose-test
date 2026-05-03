module "argocd" {
  source = "../../modules/argocd"

  providers = {
    helm = helm
  }

  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca       = module.eks.cluster_ca
  cluster_token    = data.aws_eks_cluster_auth.this.token

  depends_on = [module.eks] # ✅ giờ dùng được
}

resource "kubernetes_namespace" "argocd" {
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
}