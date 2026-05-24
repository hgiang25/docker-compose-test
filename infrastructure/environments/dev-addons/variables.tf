variable "region" {
  type = string
}

variable "state_bucket" {
  type = string
}

variable "infra_state_key" {
  type = string
}

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

variable "metrics_server_version" {
  type    = string
  default = "3.13.0"
}

variable "argo_rollouts_version" {
  type    = string
  default = "2.37.6"
}

variable "cluster_autoscaler_ver" {
  type    = string
  default = "9.37.0"
}
