resource "aws_route53_record" "jenkins_record" {
  count = var.jenkins_dns_name != "" ? 1 : 0

  zone_id = "Z029807318ZYBD0ARNFLS"
  name    = var.jenkins_dns_name
  type    = "A"

  alias {
    name                   = aws_lb.jenkins_alb.dns_name
    zone_id                = aws_lb.jenkins_alb.zone_id
    evaluate_target_health = false
  }
}