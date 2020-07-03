variable "pool_name" {
  description = "cognito user pool name"
  default     = "default"
}

variable "auto_verified_attributes" {
  description = "検証に使用する属性"
  default     = ["email"]
}

variable "client_name" {
  description = "cognito user pool client name"
  default     = "default"
}

variable "generate_secret" {
  default = true
}

variable "refresh_token_validity" {
  default = 3650
}

variable "labmda_custom_message" {
  type        = string
  default     = ""
  description = "custom trigger labmda arn"
}