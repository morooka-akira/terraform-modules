variable "name" {
  description = "service name"
}

variable "engine_name" {
  description = "db engine name"
  default     = "mysql"
}

variable "major_engine_version" {
  description = "db engine version"
  default     = "8.0"
}

variable "parameter_group_family" {
  default = "mysql8.0"
}

variable "vpc_id" {
  description = "vpc_id"
}

variable "vpc_cidr_block" {
  description = "cidr_block"
}

variable "db_subnet_ids" {
  description = "db subnet"
}

variable "db_engine" {
  default = "mysql"
}

variable "db_engine_version" {
  default = "8.0.17"
}

variable "db_allocated_storage" {
  description = "ストレージ容量"
  default = 20
}

variable "db_max_allocated_storage" {
  description = "自動的にこの値までスケーリング"
  default = 100
}

variable "db_instance_class" {
  description = "インスタンスクラス"
  default = "db.t2.micro"
}

variable "db_username" {
  description = "デフォルトユーザー"
}

variable "db_password" {
  description = "デフォルトユーザーパスワード"
}

variable "skip_final_snapshot" {
  default = true
}

variable "bastion_sg_id" {
  description = "踏み台のセキュリティグループID"
}