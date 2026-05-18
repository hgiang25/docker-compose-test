variable "cluster_name" {}
variable "cluster_endpoint" {}
variable "cluster_ca" {}
variable "oidc_provider_arn" {}
variable "region" {}

variable "metrics_server_version" {}
variable "argo_rollouts_version" {}
variable "cluster_autoscaler_ver" {}
variable "aws_lb_controller_ver" {}
variable "vpc_id" {}

variable "enable_metrics_server" {
  type    = bool
  default = true
}

variable "enable_argo_rollouts" {
  type    = bool
  default = true
}

variable "enable_cluster_autoscaler" {
  type    = bool
  default = true
}

variable "enable_aws_lb_controller" {
  type    = bool
  default = true
}