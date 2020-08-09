resource "aws_route53_record" "jenkins_record" {
  count = var.jenkins_dns_name != "" ? 1 : 0

  zone_id = "ZBX492LUUAYS7"
  name    = var.jenkins_dns_name
  type    = "A"

  alias {
    name                   = aws_elb.jenkins_elb.dns_name
    zone_id                = aws_elb.jenkins_elb.zone_id
    evaluate_target_health = false
  }
}