provider "aws" {
  region = var.region
}

locals {
  argocd_role_arn = "arn:aws:iam::${var.account_id}:role/${var.argocd_role_name}"
}

# =========================================================
# MANAGEMENT CLUSTER (where ArgoCD lives, secrets land here)
# =========================================================

data "terraform_remote_state" "management" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.management_infra_state_key
    region = var.region
  }
}

data "aws_eks_cluster_auth" "management" {
  name = data.terraform_remote_state.management.outputs.cluster_name
}

provider "kubernetes" {
  host = data.terraform_remote_state.management.outputs.cluster_endpoint

  token = data.aws_eks_cluster_auth.management.token

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.management.outputs.cluster_ca
  )
}

# =========================================================
# TARGET CLUSTERS (one remote_state per entry in target_clusters)
# =========================================================

data "terraform_remote_state" "targets" {
  for_each = var.target_clusters

  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = each.value.state_key
    region = var.region
  }
}

# =========================================================
# ARGOCD CLUSTER REGISTRATION
# =========================================================

module "argocd_clusters" {
  source = "../../modules/argocd-clusters"

  providers = {
    kubernetes = kubernetes
  }

  clusters = {
    for name, cfg in var.target_clusters :
    name => {
      cluster_name = data.terraform_remote_state.targets[name].outputs.cluster_name
      server       = data.terraform_remote_state.targets[name].outputs.cluster_endpoint
      ca_data      = data.terraform_remote_state.targets[name].outputs.cluster_ca
      region       = cfg.region
      role_arn     = local.argocd_role_arn
    }
  }
}
