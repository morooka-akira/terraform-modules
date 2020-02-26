variable "bucket" {
  description = "s3 bucket name"
}

variable "allowed_origins" {
  description = "s3 allowed_origins list"
  default = []
}

variable "force_destroy" {
  default = false
}