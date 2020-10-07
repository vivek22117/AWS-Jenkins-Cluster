data "aws_ami" "jenkins-master-ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["jenkins-master-2.X"]
  }
}


