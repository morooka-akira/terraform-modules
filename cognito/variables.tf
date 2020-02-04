variable "pool_name" {
  description = "cognito user pool name"
  default     = "default"
}

variable "auto_verified_attributes" {
  description = "検証に使用する属性"
  default     = ["email"]
}
