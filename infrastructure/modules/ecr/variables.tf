variable "repositories" {
  type = list(string)
  description = "List of ECR repository names to create."
  default = [
    "vote-app",
    "result-app",
    "worker-app"
  ]
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "scan_on_push" {
  type    = bool
  default = true
}
