resource "aws_s3_bucket" "public" {
  bucket = var.bucket
  acl    = "public-read"
  force_destroy = var.force_destroy

  dynamic "cors_rule" {
      for_each = var.allowed_origins
      content {
          allowed_origins = var.allowed_origins
          allowed_methods = ["GET"]
          allowed_headers = ["*"]
          max_age_seconds = 3000
      }
  }
}