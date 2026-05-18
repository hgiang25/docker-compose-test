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

