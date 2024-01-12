resource "aws_s3_bucket" "this" {
  bucket = "${var.name_prefix}-cronjob-output"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = false
  }
}
