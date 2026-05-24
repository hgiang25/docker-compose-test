variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "enviroment" {
  type        = string
  description = "Environment name used in IAM resource names and tags."
}

variable "cluster_version" {
  type    = string
  default = "1.34"
}

variable "cluster_endpoint_public_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_private_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "coredns_replica_count" {
  type    = number
  default = 2
}

variable "vpc_cni_config" {
  type = map(string)
  default = {
    ENABLE_PREFIX_DELEGATION     = "false"
    WARM_PREFIX_TARGET           = "1"
    MINIMUM_IP_TARGET            = "8"
    WARM_IP_TARGET               = "2"
    AWS_VPC_K8S_CNI_EXTERNALSNAT = "false"
    ENABLE_POD_ENI               = "false"
    AWS_VPC_ENI_MTU              = "9001"
  }
}

variable "node_http_ingress_from_port" {
  type    = number
  default = 30000
}

variable "node_http_ingress_to_port" {
  type    = number
  default = 32767
}

variable "node_http_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "node_group_name" {
  type    = string
  default = "default"
}

variable "node_desired_size" {
  type    = number
  default = 3
}

variable "node_min_size" {
  type    = number
  default = 3
}

variable "node_max_size" {
  type    = number
  default = 5
}

variable "node_instance_types" {
  type    = list(string)
  default = ["c7i-flex.large"]
}

variable "node_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "node_disk_size" {
  type    = number
  default = 30
}

variable "node_max_unavailable" {
  type    = number
  default = 1
}

variable "node_role_label" {
  type    = string
  default = "general"
}

variable "node_additional_iam_policies" {
  type = map(string)
  default = {
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
}

variable "admin_user_arn" {
  type        = string
  description = "IAM User ARN granted EKS cluster admin (assume + access entry)."
}

variable "argocd_role_arn" {
  type        = string
  description = "IAM Role ARN for ArgoCD cross-cluster access entry. Empty disables it."
  default     = ""
}

variable "tags" {
  type = map(string)
  default = {
    Project   = "voting-app"
    ManagedBy = "Terraform"
  }
}
