provider "aws" {
  region = var.region
}

data "terraform_remote_state" "dev" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.infra_state_key
    region = var.region
  }
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.dev.outputs.cluster_name
}

provider "kubernetes" {
  host = data.terraform_remote_state.dev.outputs.cluster_endpoint

  token = data.aws_eks_cluster_auth.this.token

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.dev.outputs.cluster_ca
  )
}

provider "helm" {
  kubernetes {
    host = data.terraform_remote_state.dev.outputs.cluster_endpoint

    token = data.aws_eks_cluster_auth.this.token

    cluster_ca_certificate = base64decode(
      data.terraform_remote_state.dev.outputs.cluster_ca
    )
  }
}

module "addons" {
  source = "../../modules/addons"

  cluster_name      = data.terraform_remote_state.dev.outputs.cluster_name
  cluster_endpoint  = data.terraform_remote_state.dev.outputs.cluster_endpoint
  cluster_ca        = data.terraform_remote_state.dev.outputs.cluster_ca
  oidc_provider_arn = data.terraform_remote_state.dev.outputs.oidc_provider_arn

  region = var.region

  vpc_id = data.terraform_remote_state.dev.outputs.vpc_id

  enable_metrics_server     = var.enable_metrics_server
  enable_argo_rollouts      = var.enable_argo_rollouts
  enable_cluster_autoscaler = var.enable_cluster_autoscaler

  metrics_server_version = var.metrics_server_version
  argo_rollouts_version  = var.argo_rollouts_version
  cluster_autoscaler_ver = var.cluster_autoscaler_ver
}
