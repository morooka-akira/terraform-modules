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

variable "email_sending_account" {
  type        = string
  default     = "COGNITO_DEFAULT"
  description = "The email delivery method to use. COGNITO_DEFAULT or DEVELOPER"
}

variable "email_source_arn" {
  type        = string
  default     = ""
  description = "The ARN of the SES verified email identity to to use."
}

variable "from_email_address" {
  type        = string
  default     = ""
  description = "Sender’s email address or sender’s display name with their email."
}

variable "labmda_custom_message" {
  type        = string
  default     = ""
  description = "custom trigger labmda arn"
}

variable "password_minimum_length" {
  type        = number
  default     = 8
  description = "The minimum length of the password policy that you have set."
}

variable "password_require_lowercase" {
  type        = bool
  default     = true
  description = "Whether you have required users to use at least one lowercase letter in their password."
}

variable "password_require_uppercase" {
  type        = bool
  default     = true
  description = "Whether you have required users to use at least one uppercase letter in their password."
}

variable "password_require_numbers" {
  type        = bool
  default     = true
  description = "Whether you have required users to use at least one number in their password."
}

variable "password_require_symbols" {
  type        = bool
  default     = true
  description = "Whether you have required users to use at least one symbol in their password."
}
