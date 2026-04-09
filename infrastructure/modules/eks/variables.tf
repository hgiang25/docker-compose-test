variable "cluster_name" {}
variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}