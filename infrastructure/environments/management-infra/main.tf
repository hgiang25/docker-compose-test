terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.36.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source = "../../modules/vpc"

  environment     = "management"
  cluster_name = "management-cluster"
  vpc_cidr        = "10.10.0.0/16"

  public_subnets = [
    "10.10.1.0/24",
    "10.10.2.0/24"
  ]

  private_subnets = [
    "10.10.3.0/24",
    "10.10.4.0/24"
  ]

  azs = [
    "ap-southeast-1a",
    "ap-southeast-1b"
  ]
}

module "eks" {
  source = "../../modules/eks"

  cluster_name = "management-cluster"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  enviroment = "management"
}


module "ecr" {
  source = "../../modules/ecr"
}

module "eks_addons" {
  source = "../../modules/addons"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_ca        = module.eks.cluster_ca
  oidc_provider_arn = module.eks.oidc_provider_arn

  region = "ap-southeast-1"
  vpc_id = module.vpc.vpc_id

  metrics_server_version = "3.13.0"
  argo_rollouts_version  = "2.37.6"

  aws_lb_controller_ver = "1.11.0"

  cluster_autoscaler_ver = "9.37.0"
}