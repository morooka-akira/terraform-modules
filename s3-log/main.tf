
# ログ格納用のs3
resource "aws_s3_bucket" "cloudwatch_logs" {
    bucket = "${var.name}-cloudwatch-logs"

    lifecycle_rule {
        enabled = true
        expiration {
            days = "180"
        }
    }
}

# ==================== firehose ======================#
# firehoseのロール
data "aws_iam_policy_document" "kinesis_firehose_data" {
   statement {
       effect = "Allow"
       actions = [
           "s3:AbortMultipartUpload",
           "s3:GetBucketLocation",
           "s3:GetObject",
           "s3:ListBucket",
           "s3:ListBucketMultipartUploads",
           "s3:PutObject"
       ]
       resources = [
           "arn:aws:s3:::${aws_s3_bucket.cloudwatch_logs.id}",
           "arn:aws:s3:::${aws_s3_bucket.cloudwatch_logs.id}/*"
       ]
   }
}

module "iam_role_kinesis_firehose" {
    source        = "../iam_role"
    name          = "${var.name}-kinesis-data-firehose"
    identifier    = "firehose.amazonaws.com"
    policy_json   = data.aws_iam_policy_document.kinesis_firehose_data.json
}

resource "aws_kinesis_firehose_delivery_stream" "default" {
    name        = var.name
    destination = "s3"

    s3_configuration {
        role_arn = module.iam_role_kinesis_firehose.iam_role_arn
        bucket_arn = aws_s3_bucket.cloudwatch_logs.arn
    }
}

# ==================== cloud watch logs サブスクリプション ======================#

# ロール
data "aws_iam_policy_document" "cloudwatch_logs" {
    statement {
        sid       = "1"
        effect    = "Allow"
        actions   = ["firehose:*"]
        resources = ["arn:aws:firehose:ap-northeast-1:*:*"]
    }

    statement {
        sid       = "2"
        effect    = "Allow"
        actions   = ["iam:PassRole"]
        resources = ["arn:aws:iam::*:role/cloudwatch-logs"]
    }
}

module "iam_role_cloudwatch_logs" {
    source        = "../iam_role"
    name          = "${var.name}-cloud_watch_log_subscription"
    identifier    = "logs.ap-northeast-1.amazonaws.com"
    policy_json   = data.aws_iam_policy_document.cloudwatch_logs.json
}
  
resource "aws_cloudwatch_log_subscription_filter" "default" {
    name            = var.name
    log_group_name  = var.log_group_name
    destination_arn = aws_kinesis_firehose_delivery_stream.default.arn
    filter_pattern  = "[]"
    role_arn        = module.iam_role_cloudwatch_logs.iam_role_arn
}
