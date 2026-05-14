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

resource "helm_release" "argo_rollouts" {
  name       = "argo-rollouts"
  namespace  = "argo-rollouts"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  version    = "2.37.6"

  create_namespace = true

  depends_on = [
    module.eks
  ]
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"

      command = "aws"

      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name,
        "--region",
        "ap-southeast-1"
      ]
    }
  }
}