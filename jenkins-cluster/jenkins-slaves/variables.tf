#####===========Global Variables==================#####
variable "profile" {
  type        = string
  description = "AWS Profile name for credentials"
}

variable "environment" {
  type        = string
  description = "Environment to be configured 'dev', 'qa', 'prod'"
}

variable "jenkins_username" {
  description = "Jenkins username"
}

variable "jenkins_password" {
  description = "Jenkins password"
}

variable "jenkins_credentials_id" {
  description = "Slaves SSH ID"
}

variable "spot_price" {
  type        = string
  description = "EC2 spot price"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type to launch!"
}

variable "instance_count" {
  type        = number
  description = "Number of jenkins slaves to launch"
}

variable "max_count" {
  type        = number
  description = "Max count for autoscaling group"
}

//Default Variables
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

#####=============ASG Standards Tags===============#####
variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default = {
    owner      = "Vivek"
    team       = "DoubleDigitTeam"
    tool       = "Terraform"
    monitoring = "true"
    Name       = "Jenkins-Salve"
  }
}

#####================Local variables===============#####
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "DoubleDigitTeam"
    environment = var.environment
  }
}

