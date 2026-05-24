variable "region" {
  type = string
}

variable "state_bucket" {
  type = string
}

variable "requester_state_key" {
  type        = string
  description = "S3 state key of the requester-side infra stack."
}

variable "accepter_state_key" {
  type        = string
  description = "S3 state key of the accepter-side infra stack."
}

variable "allowed_tcp_ports" {
  type    = list(number)
  default = [30080, 30090]
}

variable "tags" {
  type = map(string)
  default = {
    Project   = "voting-app"
    ManagedBy = "Terraform"
    Component = "vpc-peering"
  }
}
