region       = "ap-southeast-1"
state_bucket = "terraform-state-voting-app-123456"

infra_state_key = "management-infra/terraform.tfstate"

enable_metrics_server     = false
enable_argo_rollouts      = false
enable_cluster_autoscaler = false

metrics_server_version = "3.13.0"
argo_rollouts_version  = "2.37.6"
cluster_autoscaler_ver = "9.37.0"
