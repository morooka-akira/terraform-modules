resource "aws_cognito_user_pool" "pool" {
  name = var.pool_name
  auto_verified_attributes = var.auto_verified_attributes

  lambda_config {
    custom_message = var.labmda_custom_message
  }
}

resource "aws_cognito_user_pool_client" "client" {
  user_pool_id = aws_cognito_user_pool.pool.id
  name = var.client_name
  generate_secret = var.generate_secret
  refresh_token_validity = var.refresh_token_validity
}