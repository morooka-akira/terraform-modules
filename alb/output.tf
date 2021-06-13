output "alb_id" {
  value = aws_alb.default.id
}

output "alb_target_group_id" {
  value = aws_alb_target_group.default.id
}