module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0.0"

  create_cloudwatch_log_group = false

  cluster_name    = var.cluster_name
  cluster_version = "1.34"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # IRSA cho service account
  enable_irsa = true

  # Cho phép endpoint public/private
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Bootstrap admin cluster creator
  #enable_cluster_creator_admin_permissions = true

  #enable_ebs_csi_driver = true  

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    
    # 🔥 THÊM/SỬA BLOCK NÀY ĐỂ TĂNG SỐ LƯỢNG POD CHO T3.MICRO
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
          MINIMUM_IP_TARGET        = "2"
        }
      })
    }
    
    aws-ebs-csi-driver = {
      most_recent = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
      depends_on = [module.ebs_csi_irsa_role]
    }
  }

  # Node group
  eks_managed_node_groups = {
    default = {
      desired_size = 2
      max_size     = 3
      min_size     = 1

      instance_types = ["t3.small"]

      subnet_ids = var.private_subnet_ids

      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
      tags = {
        "k8s.io/cluster-autoscaler/enabled" = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }      
    }
  }

  # Tags
  tags = {
    Project     = "voting-app"
    Enviroment = var.enviroment
    ManagedBy   = "Terraform"
  }
}

# IAM Role admin (có thể assume khi cần thêm admin khác)
resource "aws_iam_role" "eks_admin_role" {
  name = "${var.enviroment}-eks-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::248195880649:user/hgiang2352"
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
  principal_arn = "arn:aws:iam::248195880649:user/hgiang2352"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::248195880649:user/hgiang2352"

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.admin
  ]
}