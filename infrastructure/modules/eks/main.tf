module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0.0"

  create_cloudwatch_log_group = false

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id = var.vpc_id

  subnet_ids = var.private_subnet_ids

  enable_irsa = true

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  cluster_addons = {

    coredns = {
      most_recent = true

      configuration_values = jsonencode({
        replicaCount = var.coredns_replica_count
      })
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent    = true
      before_compute = true

      configuration_values = jsonencode({
        env = var.vpc_cni_config
      })
    }

    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn

      depends_on = [
        module.ebs_csi_irsa_role
      ]
    }
  }

  node_security_group_additional_rules = {

    ingress_http = {
      description = "Allow HTTP NodePort range"
      protocol    = "tcp"

      from_port = var.node_http_ingress_from_port
      to_port   = var.node_http_ingress_to_port

      type        = "ingress"
      cidr_blocks = var.node_http_ingress_cidrs
    }
  }

  eks_managed_node_groups = {

    (var.node_group_name) = {

      desired_size = var.node_desired_size
      min_size     = var.node_min_size
      max_size     = var.node_max_size

      instance_types = var.node_instance_types

      capacity_type = var.node_capacity_type

      subnet_ids = var.private_subnet_ids

      disk_size = var.node_disk_size

      update_config = {
        max_unavailable = var.node_max_unavailable
      }

      labels = {
        role = var.node_role_label
      }

      taints = []

      iam_role_additional_policies = var.node_additional_iam_policies

      tags = {

        "k8s.io/cluster-autoscaler/enabled" = "true"

        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }
    }
  }

  tags = merge(var.tags, {
    Enviroment = var.enviroment
  })
}

# IAM Role admin (có thể assume khi cần thêm admin khác)
resource "aws_iam_role" "eks_admin_role" {
  name = "${var.enviroment}-eks-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = var.admin_user_arn
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "eks_admin_limited" {
  name = "${var.enviroment}-EKSAdminLimitedPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*",
          "ec2:Describe*",
          "ec2:CreateSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_admin_attach" {
  role       = aws_iam_role.eks_admin_role.name
  policy_arn = aws_iam_policy.eks_admin_limited.arn
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.enviroment}-ebs-csi-role"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn

      namespace_service_accounts = [
        "kube-system:ebs-csi-controller-sa"
      ]
    }
  }
}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.admin_user_arn
  type          = "STANDARD"

  depends_on = [
    module.eks
  ]
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.admin_user_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.admin
  ]
}

resource "aws_eks_access_entry" "argocd" {
  count = var.argocd_role_arn != "" ? 1 : 0

  cluster_name  = module.eks.cluster_name
  principal_arn = var.argocd_role_arn
  type          = "STANDARD"

  depends_on = [
    module.eks
  ]
}

resource "aws_eks_access_policy_association" "argocd" {
  count = var.argocd_role_arn != "" ? 1 : 0

  cluster_name  = module.eks.cluster_name
  principal_arn = var.argocd_role_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.argocd
  ]
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "aws_security_group_rule" "allow_nlb_to_nodes" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"

  security_group_id = module.eks.node_security_group_id

  cidr_blocks = [data.aws_vpc.this.cidr_block]

  description = "Allow NLB (IP target mode) to reach node/pods"
}
