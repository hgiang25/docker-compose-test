region       = "ap-southeast-1"
state_bucket = "terraform-state-voting-app-123456"
account_id   = "248195880649"

management_infra_state_key = "management-infra/terraform.tfstate"

argocd_role_name = "management-cluster-argocd-controller"

target_clusters = {
  dev-cluster = {
    state_key = "dev_infra/terraform.tfstate"
    region    = "ap-southeast-1"
  }
}
