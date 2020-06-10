variable "name" {
  description = "service name"
}

variable "vpc_id" {
  description = "vpc_id"
}

variable "alb_subnet_ids" {}

variable "ecs_subnet_ids" {}

variable "container_definitions" {}

variable "container_name" {}

variable "container_port" {}

variable "alb_certificate_arn" {
  description = "httpsに対応するときはACMの証明書のARNを設定する"
  default = ""
}

variable "has_autoScaling" {
  description = "autoScalingさせるか"
  default = false
}

variable "autoscaling_min_capacity" {
  default = 1
}

variable "autoscaling_max_capacity" {
  default = 2
}

variable "memory" {
  default = "2048"
}

variable "cpu" {
  default = "1024"
}