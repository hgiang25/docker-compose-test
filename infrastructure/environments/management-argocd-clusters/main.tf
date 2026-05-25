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
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

# =========================================================
# MANAGEMENT CLUSTER
# =========================================================

data "terraform_remote_state" "management" {
  backend = "s3"

  config = {
    bucket = "terraform-state-voting-app-123456"
    key    = "management-infra/terraform.tfstate"
    region = "ap-southeast-1"
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
# DEV CLUSTER
# =========================================================

data "terraform_remote_state" "dev" {
  backend = "s3"

  config = {
    bucket = "terraform-state-voting-app-123456"
    key    = "dev_infra/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# =========================================================
# PROD CLUSTER
# =========================================================

data "terraform_remote_state" "prod" {
  backend = "s3"

  config = {
    bucket = "terraform-state-voting-app-123456"

    key    = "prod_infra/terraform.tfstate"

    region = "ap-southeast-1"
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

    dev-cluster = {

      cluster_name = data.terraform_remote_state.dev.outputs.cluster_name

      server = data.terraform_remote_state.dev.outputs.cluster_endpoint

      ca_data = data.terraform_remote_state.dev.outputs.cluster_ca

      region = "ap-southeast-1"

      role_arn = "arn:aws:iam::248195880649:role/management-cluster-argocd-controller"
    }

    prod-cluster = {

      cluster_name = data.terraform_remote_state.prod.outputs.cluster_name

      server = data.terraform_remote_state.prod.outputs.cluster_endpoint

      ca_data = data.terraform_remote_state.prod.outputs.cluster_ca

      region = "ap-southeast-1"

      role_arn = "arn:aws:iam::248195880649:role/management-cluster-argocd-controller"
    }
  }
}