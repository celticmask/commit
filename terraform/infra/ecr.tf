# ECR for storing app. images
resource "aws_ecr_repository" "this" {
  name         = "commit"
  force_delete = true
  tags         = local.tags
}
