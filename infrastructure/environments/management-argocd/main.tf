provider "aws" {
  region = var.region
}

data "terraform_remote_state" "management" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.infra_state_key
    region = var.region
  }
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.management.outputs.cluster_name
}

provider "kubernetes" {
  host = data.terraform_remote_state.management.outputs.cluster_endpoint

  token = data.aws_eks_cluster_auth.this.token

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.management.outputs.cluster_ca
  )
}

provider "helm" {
  kubernetes {
    host = data.terraform_remote_state.management.outputs.cluster_endpoint

    token = data.aws_eks_cluster_auth.this.token

    cluster_ca_certificate = base64decode(
      data.terraform_remote_state.management.outputs.cluster_ca
    )
  }
}

module "argocd" {
  source = "../../modules/argocd"

  cluster_name      = data.terraform_remote_state.management.outputs.cluster_name
  oidc_provider_arn = data.terraform_remote_state.management.outputs.oidc_provider_arn

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [
    data.terraform_remote_state.management
  ]
}
