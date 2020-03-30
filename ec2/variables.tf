
variable "name" {
  description = "ec2 name"
}

variable "instance_type" {
  description = "instance type"
  default     = "t2.micro" 
}

variable "vpc_id" {
  description = "vpc_id"
}

variable "subnet_id" {
  description = "subnet_id"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "public_key" {
}

variable "ingress_ports" {
  default     = [22]
}