locals {
  admin_user_arn  = "arn:aws:iam::${var.account_id}:user/${var.admin_user_name}"
  argocd_role_arn = var.argocd_role_name == "" ? "" : "arn:aws:iam::${var.account_id}:role/${var.argocd_role_name}"
}

module "vpc" {
  source = "../../modules/vpc"

  environment  = var.environment
  cluster_name = var.cluster_name

  region = var.region

  vpc_cidr = var.vpc_cidr

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  azs = var.azs
}

module "eks" {
  source = "../../modules/eks"

  cluster_name = var.cluster_name

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  enviroment = var.environment

  admin_user_arn  = local.admin_user_arn
  argocd_role_arn = local.argocd_role_arn
}
