terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.36.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

data "terraform_remote_state" "dev" {
  backend = "s3"

  config = {
    bucket = "terraform-state-voting-app-123456"
    key    = "dev_infra/terraform.tfstate"
    region = "ap-southeast-1"
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

  region = "ap-southeast-1"

  vpc_id = data.terraform_remote_state.dev.outputs.vpc_id

  enable_metrics_server     = true
  enable_argo_rollouts      = true
  enable_cluster_autoscaler = true
  enable_aws_lb_controller  = true

  metrics_server_version = "3.13.0"
  argo_rollouts_version  = "2.37.6"
  aws_lb_controller_ver  = "1.11.0"

  cluster_autoscaler_ver = "9.37.0"
}