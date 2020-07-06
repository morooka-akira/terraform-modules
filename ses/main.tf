resource "aws_ses_domain_identity" "ses" {
  domain    = var.domain_name
}

resource "aws_route53_record" "ses_record" {
  zone_id = var.route53_zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.ses.verification_token}"]
}

resource "aws_ses_domain_dkim" "dkim" {
  domain    = var.domain_name
}

resource "aws_route53_record" "dkim_record" {
  count   = 3
  zone_id = var.route53_zone_id
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "mx-record-primary" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = "60"
  records = ["10 inbound-smtp.${var.region_code}.amazonaws.com"]
}

########################## rule #################################3
resource "aws_ses_receipt_rule_set" "sns" {
  rule_set_name = "${var.recipient_rule_name}-set"
}

resource "aws_ses_receipt_rule" "sns" {
  name          = var.recipient_rule_name
  rule_set_name = aws_ses_receipt_rule_set.sns.rule_set_name
  recipients    = var.recipient_address
  enabled       = true
  scan_enabled  = true

  sns_action {
    topic_arn   = var.sns_topic_arn
    position    = 1
  }
}

resource "aws_ses_active_receipt_rule_set" "sns" {
  rule_set_name = aws_ses_receipt_rule_set.sns.rule_set_name
}