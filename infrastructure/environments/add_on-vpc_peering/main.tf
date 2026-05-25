provider "aws" {
  region = var.region
}

data "terraform_remote_state" "requester" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.requester_state_key
    region = var.region
  }
}

data "terraform_remote_state" "accepter" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.accepter_state_key
    region = var.region
  }
}

module "peering" {
  source = "../../modules/peering"

  requester_vpc_id       = data.terraform_remote_state.requester.outputs.vpc_id
  requester_cluster_name = data.terraform_remote_state.requester.outputs.cluster_name

  accepter_vpc_id       = data.terraform_remote_state.accepter.outputs.vpc_id
  accepter_cluster_name = data.terraform_remote_state.accepter.outputs.cluster_name

  tags = var.tags
}
