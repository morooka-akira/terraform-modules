resource "aws_sns_topic" "main" {
  name = var.topic_name
}

resource "aws_sns_topic_subscription" "main" {
  count = var.has_subscription ? 1 : 0
  topic_arn = aws_sns_topic.main.arn
  protocol  = var.subscription_protocol
  endpoint  = var.subscription_endpoint
}