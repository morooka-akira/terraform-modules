########################
## CodeBuild
########################

module "codebuild_role" {
  source     = "./iam_role"
  name       = "${var.name}-codebuild"
  identifier = "codebuild.amazonaws.com"
  policy     = data.aws_iam_policy_document.codebuild.json
}

resource "aws_codebuild_project" "codebuild_project" {
  depends_on    = [module.codebuild_role]
  name          = var.name
  description   = var.description
  build_timeout = "30"
  service_role  = module.codebuild_role.iam_role_arn

  source {
    type = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:2.0"
    privileged_mode = true

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name = environment_variable.key
        value  = environment_variable.value
      }
    }
  }
}