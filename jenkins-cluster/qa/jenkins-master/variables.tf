#####========================Global Variables=======================#####
variable "profile" {
  type        = string
  description = "AWS Profile name for credentials"
}

variable "public_key" {
  type        = string
  description = "public key to create key pair for Jenkins Slaves"
}

variable "environment" {
  type        = string
  description = "Environment to be configured 'dev', 'qa', 'prod'"
}

variable "jenkins_dns_name" {
  type        = string
  description = "DNS name to be applied for jenkins cluster"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type to launch!"
}

variable "spot_price" {
  type        = string
  description = "EC2 spot price"
}

variable "efs_domain" {
  type        = string
  description = "EFS domain generated"
}


#####=====================Default Variables=====================#####
variable "default_region" {
  type    = string
  default = "us-east-1"
}

variable "dyanamoDB_prefix" {
  type    = string
  default = "doubledigit-tfstate"
}

variable "s3_bucket_prefix" {
  type    = string
  default = "doubledigit-tfstate"
}

variable "default_target_group_port" {
  type        = number
  description = "Target group port for ECS Cluster"
}

#####=============ASG Standards Tags===============#####
variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default = {
    owner      = "Vivek"
    team       = "DoubleDigitTeam"
    tool       = "Terraform"
    monitoring = "true"
    Name       = "Jenkins-Master"
    Project    = "DoubleDigit-Solutions"
  }
}

####============Local variables============#####
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "DoubleDigitTeam"
    environment = var.environment
    Project     = "DoubleDigit-Solutions"
  }
}

