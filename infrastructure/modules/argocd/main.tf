resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = var.namespace
  }
}

module "argocd_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.cluster_name}-${var.controller_role_suffix}"

  role_policy_arns = var.role_policy_arns

  oidc_providers = {
    main = {
      provider_arn = var.oidc_provider_arn

      namespace_service_accounts = var.service_accounts
    }
  }
}

resource "helm_release" "argocd" {
  name      = var.release_name
  namespace = var.namespace

  repository = var.chart_repository
  chart      = var.chart_name
  version    = var.chart_version

  create_namespace = true

  values = [
    replace(
      file("${path.module}/${var.values_file}"),
      var.irsa_role_placeholder,
      module.argocd_irsa_role.iam_role_arn
    )
  ]

  depends_on = [
    kubernetes_namespace_v1.argocd
  ]

  timeout         = var.helm_timeout
  wait            = var.helm_wait
  force_update    = var.helm_force_update
  recreate_pods   = var.helm_recreate_pods
  cleanup_on_fail = var.helm_cleanup_on_fail
  atomic          = var.helm_atomic
}
