module "cluster_autoscaler_irsa_role" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.cluster_name}-cluster-autoscaler"

  attach_cluster_autoscaler_policy = true

  cluster_autoscaler_cluster_names = [
    var.cluster_name
  ]

  oidc_providers = {
    main = {
      provider_arn = var.oidc_provider_arn

      namespace_service_accounts = [
        "${var.cluster_autoscaler_namespace}:${var.cluster_autoscaler_sa_name}"
      ]
    }
  }
}