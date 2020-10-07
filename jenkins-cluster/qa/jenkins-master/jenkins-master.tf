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
  instance_type        = var.environment == "qa" ? "t2.small" : var.instance_type
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
  depends_on = [aws_lb.jenkins_alb]

  name_prefix         = "${aws_launch_configuration.jenkins_master.name}-asg"

  vpc_zone_identifier  = data.terraform_remote_state.vpc.outputs.private_subnets
  max_size             = 3
  min_size             = var.environment == "prod" ? 2 : 1
  desired_capacity     = var.environment == "prod" ? 2 : 1
  launch_configuration = aws_launch_configuration.jenkins_master.id
  target_group_arns = [aws_lb_target_group.jenkins_target_group.arn]
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

resource "aws_lb" "jenkins_alb" {
  name = "jenkins-cluster-alb"

  subnets                   = data.terraform_remote_state.vpc.outputs.public_subnets
  security_groups           = [aws_security_group.lb_sg.id]
  internal                  = false
  enable_http2              = "true"
  idle_timeout              = 300

  tags = merge(local.common_tags, map("Name", "jenkins-master-lb"))
}


resource "aws_lb_listener" "jenkins_alb_listener" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_target_group.arn
  }
}

resource "aws_lb_target_group" "jenkins_target_group" {
  name = "jenkins-tg-${var.environment}"

  port        = var.default_target_group_port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "instance"

  tags = {
    name = "jenkins-tg"
  }

  health_check {
    enabled             = true
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200,301,302"
  }
}

resource "aws_autoscaling_attachment" "jenkins_alb_att" {
  alb_target_group_arn   = aws_lb_target_group.jenkins_target_group.arn
  autoscaling_group_name = aws_autoscaling_group.jenkins_master_asg.name
}