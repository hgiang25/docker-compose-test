terraform {
  backend "s3" {
    bucket = "terraform-state-voting-app-123456"

    key    = "prod_infra/terraform.tfstate"

    region = "ap-southeast-1"

    use_lockfile = true
  }
}