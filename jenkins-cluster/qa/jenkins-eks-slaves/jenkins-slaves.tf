#####==================Jenkins slaves resource template===================#####
data "template_file" "user_data_slave" {
  template = file("scripts/join-cluster.tpl")

  vars = {
    jenkins_url            = "http://${data.terraform_remote_state.jenkins-master.outputs.jenkins_elb_dns}"
    jenkins_username       = var.jenkins_username
    jenkins_password       = var.jenkins_password
    jenkins_credentials_id = var.jenkins_credentials_id
    environment            = var.environment
  }
}

#####=============enkins slaves launch configuration=========================#####
resource "aws_launch_configuration" "jenkins_slave_launch_conf" {
  name_prefix = "jenkins-slave-"

  image_id        = data.aws_ami.jenkins-slave-ami.id
  instance_type   = var.environment == "prod" ? "t2.small" : var.instance_type
  key_name        = data.terraform_remote_state.jenkins-master.outputs.jenkins_key
  security_groups = [aws_security_group.jenkins_slaves_eks_sg.id]

  user_data                   = data.template_file.user_data_slave.rendered
  iam_instance_profile        = data.terraform_remote_state.jenkins-master.outputs.jenkins_profile
  associate_public_ip_address = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
  }

  spot_price = var.spot_price

  lifecycle {
    create_before_destroy = true
  }
}

#####===========================ASG Jenkins slaves===============================#####
resource "aws_autoscaling_group" "jenkins_slaves_asg" {
  name_prefix = "${aws_launch_configuration.jenkins_slave_launch_conf.name}-asg"

  max_size             = var.max_count
  min_size             = var.environment == "prod" ? 2 : var.instance_count
  desired_capacity     = var.environment == "prod" ? 2 : var.instance_count
  vpc_zone_identifier  = data.terraform_remote_state.vpc.outputs.private_subnets
  launch_configuration = aws_launch_configuration.jenkins_slave_launch_conf.name

  health_check_grace_period = 100
  health_check_type         = "EC2"

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


#####===============Jenkins Slave ASG scalaing alarm and policy==================#####
resource "aws_cloudwatch_metric_alarm" "high_cpu_jenkins_slaves_alarm" {
  alarm_name          = "high-cpu-jenkins-slaves-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.jenkins_slaves_asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-jenkins-slaves"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.jenkins_slaves_asg.name
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_jenkins_slaves_alarm" {
  alarm_name          = "low-cpu-jenkins-slaves-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.jenkins_slaves_asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_in.arn]
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in-jenkins-slaves"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.jenkins_slaves_asg.name
}

