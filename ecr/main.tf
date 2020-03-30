########################
## ECR
########################

# ECS Repository
resource "aws_ecr_repository" "repository" {
  name = var.name
}

# Repositry Policy
# Permit pull image
resource "aws_ecr_repository_policy" "repository_policy" {
  depends_on = [aws_ecr_repository.repository]
  repository = aws_ecr_repository.repository.name

  policy = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "new statement",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
      }
    ]
  }
EOF
}