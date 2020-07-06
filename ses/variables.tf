variable "domain_name" {
  description = "domain name"
}

variable "route53_zone_id" {
  description = "route53 host zone id"
  type = string
}

variable "region_code" {
  description = "Region code used for endpoint of mx record"
  type        = string
  default     = "us-west-2"
}

variable "recipient_rule_name" {
  description = "recipient rule name"
  type        = string
}

variable "recipient_address" {
  description = "recipient address list"
  default     = []
}

variable "sns_topic_arn" {
  description = "recipient sns topic arn"
  type        = string
}