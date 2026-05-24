resource "aws_ecr_repository" "this" {
  for_each = toset(var.repositories)

  name                 = each.value
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

# Preserve existing state addresses (vote / result / worker) so the rename
# from named resources to for_each does not destroy/recreate the repos.
moved {
  from = aws_ecr_repository.vote
  to   = aws_ecr_repository.this["vote-app"]
}

moved {
  from = aws_ecr_repository.result
  to   = aws_ecr_repository.this["result-app"]
}

moved {
  from = aws_ecr_repository.worker
  to   = aws_ecr_repository.this["worker-app"]
}
