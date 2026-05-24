region          = "ap-southeast-1"
account_id      = "248195880649"
admin_user_name = "hgiang2352"

environment  = "dev"
cluster_name = "dev-cluster"

vpc_cidr = "10.0.0.0/16"

public_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnets = [
  "10.0.3.0/24",
  "10.0.4.0/24"
]

azs = [
  "ap-southeast-1a",
  "ap-southeast-1b"
]

# ArgoCD lives on the management cluster. The IAM role the controller assumes
# to register/operate this dev cluster — created by environments/management-argocd.
argocd_role_name = "management-cluster-argocd-controller"
