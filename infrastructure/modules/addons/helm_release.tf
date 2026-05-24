locals {
  charts = merge(

    var.enable_metrics_server ? {
      metrics_server = {
        name      = var.metrics_server_chart
        repo      = var.metrics_server_repo
        chart     = var.metrics_server_chart
        version   = var.metrics_server_version
        namespace = var.metrics_server_namespace

        sets = var.metrics_server_sets
      }
    } : {},

    var.enable_argo_rollouts ? {
      argo_rollouts = {
        name      = var.argo_rollouts_chart
        repo      = var.argo_rollouts_repo
        chart     = var.argo_rollouts_chart
        version   = var.argo_rollouts_version
        namespace = var.argo_rollouts_namespace

        sets = {}
      }
    } : {},

    var.enable_cluster_autoscaler ? {
      cluster_autoscaler = {
        name      = var.cluster_autoscaler_chart
        repo      = var.cluster_autoscaler_repo
        chart     = var.cluster_autoscaler_chart
        version   = var.cluster_autoscaler_ver
        namespace = var.cluster_autoscaler_namespace

        sets = {
          "autoDiscovery.clusterName" = var.cluster_name
          "awsRegion"                 = var.region

          "extraArgs.balance-similar-node-groups" = "true"
          "extraArgs.skip-nodes-with-system-pods" = "false"

          "rbac.serviceAccount.create" = "true"
          "rbac.serviceAccount.name"   = var.cluster_autoscaler_sa_name

          "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.cluster_autoscaler_irsa_role[0].iam_role_arn
        }
      }
    } : {}
  )
}

resource "helm_release" "addons" {
  for_each = local.charts

  name             = each.value.name
  repository       = each.value.repo
  chart            = each.value.chart
  version          = each.value.version
  namespace        = each.value.namespace

  create_namespace = true

  atomic = var.helm_atomic
  wait   = var.helm_wait

  timeout = var.helm_timeout

  dynamic "set" {
    for_each = each.value.sets

    content {
      name  = set.key
      value = set.value
    }
  }
  depends_on = [
    module.cluster_autoscaler_irsa_role
  ]
}
