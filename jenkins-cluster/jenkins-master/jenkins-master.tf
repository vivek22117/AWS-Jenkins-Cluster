resource "aws_key_pair" "jenkins_master" {
  key_name   = "jenkins-key"
  public_key = var.public_key
}

resource "aws_launch_configuration" "jenkins_master" {
  # Launch Configurations cannot be updated after creation with the AWS API.
  # In order to update a Launch Configuration, Terraform will destroy the
  # existing resource and create a replacement.
  #  # We're only setting the name_prefix here,
  # Terraform will add a random string at the end to keep it unique.

  name_prefix          = "jenkins-"
  image_id             = data.aws_ami.jenkins-master-ami.id
  instance_type        = var.environment == "dev" ? "t2.small" : var.instance_type
  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.id
  key_name             = aws_key_pair.jenkins_master.key_name
  security_groups      = [aws_security_group.jenkins_master_sg.id]

  user_data = data.template_file.script.rendered

  associate_public_ip_address = false
  enable_monitoring           = false

  spot_price = var.spot_price

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jenkins_master_asg" {
  name = "${aws_launch_configuration.jenkins_master.name}-asg"

  vpc_zone_identifier  = data.terraform_remote_state.vpc.outputs.private_subnets
  max_size             = 3
  min_size             = var.environment == "prod" ? 2 : 1
  desired_capacity     = var.environment == "prod" ? 2 : 1
  launch_configuration = aws_launch_configuration.jenkins_master.id
  load_balancers       = [aws_elb.jenkins_elb.name]
  health_check_type    = "ELB"

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = var.custom_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_elb" "jenkins_elb" {
  subnets                   = data.terraform_remote_state.vpc.outputs.public_subnets
  cross_zone_load_balancing = true
  security_groups           = [aws_security_group.lb_sg.id]
  internal                  = false

  /*  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "https"
  }*/

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8080"
    interval            = 5
  }

  tags = merge(local.common_tags, map("Name", "jenkins-master-lb"))
}

