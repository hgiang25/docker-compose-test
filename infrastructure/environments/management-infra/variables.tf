variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "admin_user_name" {
  type        = string
  description = "IAM user granted EKS admin via assume-role + access entry."
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
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
