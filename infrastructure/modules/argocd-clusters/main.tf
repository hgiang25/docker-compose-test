resource "kubernetes_secret" "cluster" {
  for_each = var.clusters

  metadata {
    name      = each.key
    namespace = var.namespace

    labels = {
      "argocd.argoproj.io/secret-type" = var.secret_type_label
    }
  }

  type = "Opaque"

  data = {
    name   = each.key
    server = each.value.server

    config = jsonencode({
      awsAuthConfig = {
        clusterName = each.value.cluster_name
      }

      tlsClientConfig = {
        insecure = var.tls_insecure
        caData   = each.value.ca_data
      }
    })
  }
}
