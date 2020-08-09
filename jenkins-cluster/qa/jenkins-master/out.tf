output "jenkins_role" {
  value = aws_iam_role.jenkins_access_role.arn
}

output "jenkins_elb_dns" {
  value = aws_elb.jenkins_elb.dns_name
}

output "jenkins_master_sg" {
  value = aws_security_group.jenkins_master_sg.id
}

output "jenkins_key" {
  value = aws_key_pair.jenkins_master.key_name
}

output "jenkins_profile" {
  value = aws_iam_instance_profile.jenkins_profile.arn
}

output "route53_public_dns_name" {
  value = aws_route53_record.jenkins_record.*.name[0]
}