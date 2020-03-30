variable "name" {
  description = "pipeline name"
  default = "pipeline_name"
}

variable "codebuild_id" {
  description = "codebuild id"
}

variable "github_owner" {
  description = "github owner"
}

variable "github_repo" {
  description = "github repogitory"
}

variable "github_branch" {
  description = "github branch name"
}

variable "github_secret_token" {
  description = "github secret token"
}

variable "cluster_name" {}

variable "service_name" {}
