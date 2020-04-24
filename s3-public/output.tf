output "bucket_name" {
  value = replace(aws_s3_bucket.public.bucket_domain_name, ".s3.amazonaws.com", "")
}

output "endpoint" {
  value = aws_s3_bucket.public.website_endpoint
}
