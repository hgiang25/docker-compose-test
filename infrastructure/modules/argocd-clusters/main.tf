resource "kubernetes_secret" "cluster" {
  for_each = var.clusters

  metadata {
    name      = each.key
    namespace = "argocd"

    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
  }

  type = "Opaque"

  data = {
    name = each.key

    server = each.value.server

    config = jsonencode({
      awsAuthConfig = {
        clusterName = each.value.cluster_name
        roleARN     = each.value.role_arn
      }

      tlsClientConfig = {
        insecure = false
        caData   = each.value.ca_data
      }
    })
  }
}