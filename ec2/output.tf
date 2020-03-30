output "public_ip" {
  value = aws_eip.default.public_ip
}

output "security_group_id" {
  value = aws_security_group.ec2.id
}