output "ecr_name" {
  value = aws_ecr_repository.this.repository_url
}
