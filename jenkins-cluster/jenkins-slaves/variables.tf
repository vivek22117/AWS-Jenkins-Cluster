//Global Variables
variable "profile" {
  type        = string
  description = "AWS Profile name for credentials"
}

variable "environment" {
  type        = string
  description = "AWS Profile name for credentials"
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

//Local variables
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "TeamConcept"
    environment = var.environment
  }
}

