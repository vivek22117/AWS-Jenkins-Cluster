#####============Security Group for Jenkins Slaves=================#####
resource "aws_security_group" "jenkins_slaves_eks_sg" {
  name = "jenkins-slaves-eks-sg"

  description = "Allow traffic on port 22 from Jenkins Master"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = merge(local.common_tags, map("Name", "jenkins-slave-eks-sg"))
}

resource "aws_security_group_rule" "allow_ssh_traffic_for_slaves" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jenkins_slaves_eks_sg.id
  source_security_group_id = data.terraform_remote_state.jenkins-master.outputs.jenkins_master_sg
}

resource "aws_security_group_rule" "allow_ssh_traffic_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jenkins_slaves_eks_sg.id
  source_security_group_id = data.terraform_remote_state.vpc.outputs.bastion_sg
}

resource "aws_security_group_rule" "allow_outbound_traffic" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_slaves_eks_sg.id
}

