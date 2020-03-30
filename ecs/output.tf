output "cluster_name" {
  value = aws_ecs_cluster.default.name
}

output "service_name" {
  value = aws_ecs_service.default.name
}