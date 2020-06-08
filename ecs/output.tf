output "cluster_name" {
  value = aws_ecs_cluster.default.name
}

output "service_name" {
  value = aws_ecs_service.default.name
}

output "alb_id" {
  value = aws_alb.default.id
}

output "alb_target_group_id" {
  value = aws_alb_target_group.default.id
}