variable "name" {
  description = "build project name"
  default = "codebuild_name"
}

variable "description" {
  description = "project description"
  default = "codebuild_description"
}

variable "environment_variables" {
  description = "environment variables map"
}