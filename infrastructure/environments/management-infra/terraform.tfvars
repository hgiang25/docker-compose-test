region          = "ap-southeast-1"
account_id      = "248195880649"
admin_user_name = "hgiang2352"

environment  = "management"
cluster_name = "management-cluster"

vpc_cidr = "10.10.0.0/16"

public_subnets = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

private_subnets = [
  "10.10.3.0/24",
  "10.10.4.0/24"
]

azs = [
  "ap-southeast-1a",
  "ap-southeast-1b"
]
