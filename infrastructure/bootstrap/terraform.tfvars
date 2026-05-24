region               = "ap-southeast-1"
state_bucket         = "terraform-state-voting-app-123456"
lock_table           = "terraform-lock"
force_destroy_bucket = true

tags = {
  Name = "terraform-state"
}
