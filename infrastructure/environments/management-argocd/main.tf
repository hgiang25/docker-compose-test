terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.36.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }

    time = {    
        source = "hashicorp/time"
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

module "argocd" {
  source = "../../modules/argocd"

  cluster_name     = data.terraform_remote_state.management.outputs.cluster_name
  oidc_provider_arn = data.terraform_remote_state.management.outputs.oidc_provider_arn

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}