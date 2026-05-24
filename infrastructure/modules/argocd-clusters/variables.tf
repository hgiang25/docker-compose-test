variable "clusters" {
  type = map(object({
    cluster_name = string
    server       = string
    ca_data      = string
    region       = string
    role_arn     = string
  }))
  description = "ArgoCD cluster registrations keyed by secret name."
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "tls_insecure" {
  type    = bool
  default = false
}

variable "secret_type_label" {
  type    = string
  default = "cluster"
}
