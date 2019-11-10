//Global Variables
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
  description = "AWS Profile name for credentials"
}


//Default Variables
variable "default_region" {
  type    = string
  default = "us-east-1"
}

variable "dyanamoDB_prefix" {
  type    = string
  default = "teamconcept-tfstate"
}

variable "s3_bucket_prefix" {
  type    = string
  default = "teamconcept-tfstate"
}

#####=============ASG Standards Tags===============#####
variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default = {
    owner       = "vivek"
    team        = "doubledigit-solutions"
    tool        = "Terraform"
    monitoring  = "true"
    Name        = "Jenkins-Master"
  }
}

####============Local variables============#####
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "TeamConcept"
    environment = var.environment
  }
}

