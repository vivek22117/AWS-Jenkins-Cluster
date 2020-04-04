resource "aws_efs_file_system" "jenkins_efs" {
  creation_token = "Jenkins EFS Shared Data"

  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
  encrypted        = var.isEncrypted

  lifecycle_policy {
    transition_to_ia = var.efs_lifecycle
  }

  tags = merge(local.common_tags, map("Name", "jenkins-master-efs"))
}


resource "aws_efs_mount_target" "efs-mt-example" {
  count = length(data.terraform_remote_state.vpc.outputs.private_subnets)

  file_system_id = aws_efs_file_system.jenkins_efs.id
  subnet_id      = element(data.terraform_remote_state.vpc.outputs.private_subnets, count.index)

  security_groups = [aws_security_group.jenkins-efs-sg.id]
}


#####==============Security Group for Elastic File System=============#####
resource "aws_security_group" "jenkins-efs-sg" {
  name        = "jenkins-efs-sg"
  description = "Security group for efs traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = merge(local.common_tags, map("Name", "jenkins-efs-sg"))
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins-efs-sg.id
  cidr_blocks       = [data.terraform_remote_state.vpc.outputs.vpc_cidr]
}

resource "aws_security_group_rule" "allow_outbound_traffic_lb" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [data.terraform_remote_state.vpc.outputs.vpc_cidr]
  security_group_id = aws_security_group.jenkins-efs-sg.id
}
