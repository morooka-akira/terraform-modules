output "bucket_name" {
  value = replace(aws_s3_bucket.public.bucket_domain_name, ".s3.amazonaws.com", "")
}

output "domain_name" {
  value = aws_s3_bucket.public.bucket_regional_domain_name
}
