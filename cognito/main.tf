resource "aws_cognito_user_pool" "pool" {
  name = var.pool_name
  auto_verified_attributes = var.auto_verified_attributes
}
