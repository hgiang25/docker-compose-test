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
  type = string
}

variable "argocd_role_arn" {
  type    = string
  default = ""
}