terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.36"
    }

    time = {
      source = "hashicorp/time"
    }
  }
}