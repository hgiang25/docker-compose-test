variable "environment" {
  type        = string
  description = "Environment name used in resource Name tags."
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name used in subnet kubernetes.io tags."
}

variable "region" {
  type        = string
  description = "AWS region. Used to build VPC endpoint service names."
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = true
}

variable "vpce_ingress_port" {
  type        = number
  description = "Port allowed on the VPC endpoint security group (HTTPS API traffic)."
  default     = 443
}
