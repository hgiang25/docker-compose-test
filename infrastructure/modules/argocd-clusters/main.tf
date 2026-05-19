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
      execProviderConfig = {
        command = "aws"

        args = [
          "eks",
          "get-token",
          "--cluster-name",
          each.value.cluster_name,
          "--region",
          each.value.region
        ]

        apiVersion = "client.authentication.k8s.io/v1beta1"
      }

      tlsClientConfig = {
        insecure = false
        caData   = each.value.ca_data
      }
    }))
  }
}