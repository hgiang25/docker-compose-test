variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
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

variable "metrics_server_namespace" {
  type    = string
  default = "kube-system"
}

variable "argo_rollouts_namespace" {
  type    = string
  default = "argo-rollouts"
}

variable "cluster_autoscaler_namespace" {
  type    = string
  default = "kube-system"
}

variable "metrics_server_repo" {
  type    = string
  default = "https://kubernetes-sigs.github.io/metrics-server/"
}

variable "metrics_server_chart" {
  type    = string
  default = "metrics-server"
}

variable "argo_rollouts_repo" {
  type    = string
  default = "https://argoproj.github.io/argo-helm"
}

variable "argo_rollouts_chart" {
  type    = string
  default = "argo-rollouts"
}

variable "cluster_autoscaler_repo" {
  type    = string
  default = "https://kubernetes.github.io/autoscaler"
}

variable "cluster_autoscaler_chart" {
  type    = string
  default = "cluster-autoscaler"
}

variable "cluster_autoscaler_sa_name" {
  type    = string
  default = "cluster-autoscaler"
}

variable "metrics_server_sets" {
  type = map(string)
  default = {
    "apiService.create" = "true"
    "args[0]"           = "--kubelet-insecure-tls"
    "args[1]"           = "--kubelet-preferred-address-types=InternalIP"
  }
}

variable "helm_timeout" {
  type    = number
  default = 600
}

variable "helm_atomic" {
  type    = bool
  default = true
}

variable "helm_wait" {
  type    = bool
  default = true
}
