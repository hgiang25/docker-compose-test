variable "region" {
  type = string
}

variable "state_bucket" {
  type = string
}

variable "account_id" {
  type = string
}

variable "management_infra_state_key" {
  type = string
}

variable "argocd_role_name" {
  type        = string
  description = "IAM role (in account_id) used by ArgoCD controller on management to reach target clusters."
}

variable "target_clusters" {
  type = map(object({
    state_key = string
    region    = string
  }))
  description = "Map of ArgoCD cluster registrations keyed by secret name. state_key points to the target cluster's S3 state."
}
