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
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source = "../../modules/vpc"

  environment     = "dev"
  vpc_cidr        = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnets = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]

  azs = [
    "ap-southeast-1a",
    "ap-southeast-1b"
  ]
}

module "eks" {
  source = "../../modules/eks"

  cluster_name = "dev-cluster"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  enviroment = "dev"
}

# Gọi module addons duy nhất thay vì khai báo rời rạc
module "eks_addons" {
  source = "../../modules/addons"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_ca        = module.eks.cluster_ca
  oidc_provider_arn = module.eks.oidc_provider_arn
  region            = "ap-southeast-1"

  metrics_server_version = "3.13.0"
  argo_rollouts_version  = "2.37.6"
  cluster_autoscaler_ver = "9.37.0"
}