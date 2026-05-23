resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

module "argocd_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.cluster_name}-argocd-controller"

  role_policy_arns = {
    eksWorker = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    eksCluster = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  }

  oidc_providers = {
    main = {
      provider_arn = var.oidc_provider_arn

      namespace_service_accounts = [
        "argocd:argocd-application-controller",
        "argocd:argocd-server"
      ]
    }
  }
}

resource "helm_release" "argocd" {
  name      = "argocd"
  namespace = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"

  create_namespace = true

  values = [
    replace(
      file("${path.module}/values.yaml"),
      "$${ARGOCD_IRSA_ROLE_ARN}",
      module.argocd_irsa_role.iam_role_arn
    )
  ]

  depends_on = [
    kubernetes_namespace_v1.argocd
  ]

  timeout         = 1200
  wait            = false
  force_update    = true
  recreate_pods   = true
  cleanup_on_fail = false
  atomic          = false
}