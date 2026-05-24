region       = "ap-southeast-1"
state_bucket = "terraform-state-voting-app-123456"

# Peering direction: management (requester) -> dev (accepter)
requester_state_key = "management-infra/terraform.tfstate"
accepter_state_key  = "dev_infra/terraform.tfstate"

allowed_tcp_ports = [30080, 30090]

tags = {
  Project   = "voting-app"
  ManagedBy = "Terraform"
  Component = "vpc-peering"
}
