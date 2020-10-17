data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    profile = "admin"
    bucket  = "${var.s3_bucket_prefix}-${var.environment}-${var.default_region}"
    key     = "state/${var.environment}/vpc/terraform.tfstate"
    region  = var.default_region
  }
}


#####================Jenkins Master state file==================#####
data "terraform_remote_state" "jenkins-master" {
  backend = "s3"

  config = {
    profile = "admin"
    bucket  = "${var.s3_bucket_prefix}-${var.environment}-${var.default_region}"
    key     = "state/${var.environment}/jenkins-master-cluster/terraform.tfstate"
    region  = var.default_region
  }
}

