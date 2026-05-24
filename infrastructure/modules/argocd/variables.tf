terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.36.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }
}

variable "cluster_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "release_name" {
  type    = string
  default = "argocd"
}

variable "chart_repository" {
  type    = string
  default = "https://argoproj.github.io/argo-helm"
}

variable "chart_name" {
  type    = string
  default = "argo-cd"
}

variable "chart_version" {
  type    = string
  default = "5.51.6"
}

variable "controller_role_suffix" {
  type    = string
  default = "argocd-controller"
}

variable "service_accounts" {
  type = list(string)
  default = [
    "argocd:argocd-application-controller",
    "argocd:argocd-server"
  ]
}

variable "role_policy_arns" {
  type = map(string)
  default = {
    eksWorker  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    eksCluster = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  }
}

variable "helm_timeout" {
  type    = number
  default = 1200
}

variable "helm_wait" {
  type    = bool
  default = false
}

variable "helm_force_update" {
  type    = bool
  default = true
}

variable "helm_recreate_pods" {
  type    = bool
  default = true
}

variable "helm_cleanup_on_fail" {
  type    = bool
  default = false
}

variable "helm_atomic" {
  type    = bool
  default = false
}

variable "values_file" {
  type        = string
  description = "Path to the values yaml template (relative to the module)."
  default     = "values.yaml"
}

variable "irsa_role_placeholder" {
  type        = string
  description = "Placeholder token in values_file replaced by the IRSA role ARN."
  default     = "$${ARGOCD_IRSA_ROLE_ARN}"
}
