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