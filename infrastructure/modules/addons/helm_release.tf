locals {
  charts = merge(

    var.enable_metrics_server ? {
      metrics_server = {
        name      = "metrics-server"
        repo      = "https://kubernetes-sigs.github.io/metrics-server/"
        chart     = "metrics-server"
        version   = var.metrics_server_version
        namespace = "kube-system"

        sets = {
          "apiService.create" = "true"
          "args[0]"           = "--kubelet-insecure-tls"
          "args[1]"           = "--kubelet-preferred-address-types=InternalIP"
        }
      }
    } : {},

    var.enable_argo_rollouts ? {
      argo_rollouts = {
        name      = "argo-rollouts"
        repo      = "https://argoproj.github.io/argo-helm"
        chart     = "argo-rollouts"
        version   = var.argo_rollouts_version
        namespace = "argo-rollouts"

        sets = {}
      }
    } : {},

    var.enable_cluster_autoscaler ? {
      cluster_autoscaler = {
        name      = "cluster-autoscaler"
        repo      = "https://kubernetes.github.io/autoscaler"
        chart     = "cluster-autoscaler"
        version   = var.cluster_autoscaler_ver
        namespace = "kube-system"

        sets = {
          "autoDiscovery.clusterName" = var.cluster_name
          "awsRegion"                 = var.region

          "extraArgs.balance-similar-node-groups" = "true"
          "extraArgs.skip-nodes-with-system-pods" = "false"

          "rbac.serviceAccount.create" = "true"
          "rbac.serviceAccount.name"   = "cluster-autoscaler"

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

  atomic = true
  wait   = true

  timeout = 600

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

