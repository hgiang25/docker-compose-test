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
    name   = base64encode(each.key)

    server = base64encode(each.value.server)

    config = base64encode(jsonencode({
      awsAuthConfig = {
        clusterName = each.value.cluster_name
        roleARN     = each.value.role_arn
      }

      tlsClientConfig = {
        insecure = false
        caData   = each.value.ca_data
      }
    }))
  }
}