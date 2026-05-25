variable "requester_vpc_id" {
  type        = string
  description = "VPC ID of the requester side (e.g. management)"
}

variable "accepter_vpc_id" {
  type        = string
  description = "VPC ID of the accepter side (e.g. dev)"
}

variable "requester_cluster_name" {
  type        = string
  description = "EKS cluster name on the requester side. Used to locate the node security group."
}

variable "accepter_cluster_name" {
  type        = string
  description = "EKS cluster name on the accepter side. Used to locate the node security group."
}

variable "auto_accept" {
  type        = bool
  description = "Auto-accept the peering connection (only valid when both VPCs are in the same account and region)."
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
