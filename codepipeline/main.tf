########################
## CodeBuild
########################

module "codepipeline_role" {
  source     = "./iam_role"
  name       = "${var.name}-codepipeline"
  identifier = "codepipeline.amazonaws.com"
  policy     = data.aws_iam_policy_document.codepipeline.json
}

resource "aws_s3_bucket" "artifact" {
  bucket = "${var.name}-codepipeline"

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}

resource "aws_codepipeline" "project" {
  depends_on  = [aws_s3_bucket.artifact, module.codepipeline_role]
  name        = var.name
  role_arn    = module.codepipeline_role.iam_role_arn

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = 1
      output_artifacts = ["Source"]

      configuration = {
        Owner                = var.github_owner
        Repo                 = var.github_repo
        Branch               = var.github_branch
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      input_artifacts  = ["Source"]
      output_artifacts = ["Build"]

      configuration = {
        ProjectName = var.codebuild_id
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = 1
      input_artifacts = ["Build"]

      configuration = {
        ClusterName = var.cluster_name
        ServiceName = var.service_name
        FileName    = "imagedefinitions.json"
      }
    }
  }

  artifact_store {
    location = aws_s3_bucket.artifact.id
    type     = "S3"
  }
}

resource "aws_codepipeline_webhook" "default" {
  name            = var.name
  target_pipeline = aws_codepipeline.project.name
  target_action   = "Source"
  authentication  = "GITHUB_HMAC"

  authentication_configuration {
    secret_token = var.github_secret_token
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

resource "github_repository_webhook" "default" {
  depends_on  = [aws_codepipeline_webhook.default]
  repository = var.github_repo

  configuration {
    url          = aws_codepipeline_webhook.default.url
    content_type = "json"
    insecure_ssl = true
    secret       = var.github_secret_token
  }

  events = ["push"]
}
