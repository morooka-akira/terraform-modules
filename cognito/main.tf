resource "aws_cognito_user_pool" "pool" {
  name = var.pool_name
  auto_verified_attributes = var.auto_verified_attributes

  email_configuration {
    email_sending_account = var.email_sending_account
    source_arn            = var.email_source_arn
    from_email_address    = var.from_email_address
  }

  lambda_config {
    custom_message = var.labmda_custom_message
  }

  password_policy {
    minimum_length    = var.password_minimum_length
    require_lowercase = var.password_require_lowercase
    require_uppercase = var.password_require_uppercase
    require_numbers   = var.password_require_numbers
    require_symbols   = var.password_require_symbols
  }
}

resource "aws_cognito_user_pool_client" "client" {
  user_pool_id = aws_cognito_user_pool.pool.id
  name = var.client_name
  generate_secret = var.generate_secret
  refresh_token_validity = var.refresh_token_validity
}