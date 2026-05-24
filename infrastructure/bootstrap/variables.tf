variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "state_bucket" {
  type        = string
  description = "S3 bucket name for Terraform remote state (must be globally unique)."
  default     = "terraform-state-voting-app-123456"
}

variable "lock_table" {
  type    = string
  default = "terraform-lock"
}

variable "force_destroy_bucket" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {
    Name = "terraform-state"
  }
}
