variable "name" {
  description = "service name"
}

variable "vpc_id" {
  description = "vpc_id"
}

variable "alb_subnet_ids" {
  default     = []
}

variable "target_type" {
  description = "instance or ip"
  default     = "instance"
}

variable "health_check_path" {
  default     = "/"
}

variable "alb_certificate_arn" {
  description = "httpsに対応するときはACMの証明書のARNを設定する"
  default = ""
}