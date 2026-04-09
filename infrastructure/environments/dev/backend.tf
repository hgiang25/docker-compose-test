terraform {
  backend "s3" {
    bucket         = "terraform-state-voting-app-123456"
    key            = "dev/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-lock"
  }
}