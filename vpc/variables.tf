variable "name_prefix" {
  default = "name_prefix"
}

variable "vpc_cidr_block" {
  description = "vpc cider_block"
  default = "172.31.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}