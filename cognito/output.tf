output "user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "crient_id" {
  value = aws_cognito_user_pool_client.client.id
}