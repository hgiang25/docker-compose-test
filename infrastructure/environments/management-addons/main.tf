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

data "terraform_remote_state" "management" {
  backend = "s3"

  config = {
    bucket = "terraform-state-voting-app-123456"
    key    = "management-infra/terraform.tfstate"
    region = "ap-southeast-1"
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

module "addons" {
  source = "../../modules/addons"

  cluster_name      = data.terraform_remote_state.management.outputs.cluster_name
  cluster_endpoint  = data.terraform_remote_state.management.outputs.cluster_endpoint
  cluster_ca        = data.terraform_remote_state.management.outputs.cluster_ca
  oidc_provider_arn = data.terraform_remote_state.management.outputs.oidc_provider_arn

  region = "ap-southeast-1"

  vpc_id = data.terraform_remote_state.management.outputs.vpc_id

  enable_metrics_server      = false
  enable_argo_rollouts       = false
  enable_cluster_autoscaler  = false

  metrics_server_version = "3.13.0"
  argo_rollouts_version  = "2.37.6"

  cluster_autoscaler_ver = "9.37.0"
}