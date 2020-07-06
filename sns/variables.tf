variable "topic_name" {
  description = "sns topic name"
  type        = string
}

variable "has_subscription" {
  type        = bool
  default     = false
}

variable "subscription_protocol" {
  description = "sns topic subscription protocol[application http https lambda sms sqs]"
  type        = string
  default     = ""
}

variable "subscription_endpoint" {
  description = "sns topic subscription endpoint"
  type        = string
  default     = ""
}