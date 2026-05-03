terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.36.0"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  environment     = var.environment
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
}

module "eks" {
  source = "../../modules/eks"

  # ✅ FIX QUAN TRỌNG: phải trùng CI/CD của bạn
  cluster_name = "voting-cluster"

  vpc_id  = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}


module "argocd" {
  source = "../../modules/argocd"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  depends_on = [module.eks]
}

# ========================
# K8S AUTH (🔥 QUAN TRỌNG)
# ========================
data "aws_eks_cluster_auth" "this" {
  name = "voting-cluster"
}


provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.this.token
  cluster_ca_certificate = base64decode(module.eks.cluster_ca) # ✅ FIX
}


provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.this.token
    cluster_ca_certificate = base64decode(module.eks.cluster_ca)
  }
}