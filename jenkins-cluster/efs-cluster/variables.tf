#####========================Global Variables=======================#####
variable "profile" {
  type        = string
  description = "AWS Profile name for credentials"
}

variable "environment" {
  type        = string
  description = "Environment to be configured 'dev', 'qa', 'prod'"
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

variable "performance_mode" {
  type        = string
  description = "The file system performance mode. Can be either 'generalPurpose' or 'maxIO'"
}

variable "throughput_mode" {
  type        = string
  description = "Throughput mode for the file system, valid values bursting, provisioned"
}

variable "isEncrypted" {
  type        = bool
  description = "If 'true', the disk will be encrypted."
}

variable "efs_lifecycle" {
  type        = string
  description = "Lifecycle to transition data to IA, valid values AFTER_7_DAYS | AFTER_14_DAYS | AFTER_30_DAYS | AFTER_60_DAYS | AFTER_90_DAYS"
}
####============Local variables============#####
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "DoubleDigitTeam"
    environment = var.environment
  }
}

