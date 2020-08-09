output "efs_id" {
  value = aws_efs_file_system.jenkins_efs.id
}

output "efs_dns" {
  value = aws_efs_file_system.jenkins_efs.dns_name
}