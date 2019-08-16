data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    profile = "doubledigit"
    bucket  = "${var.s3_bucket_prefix}-${var.environment}-${var.default_region}"
    key     = "state/${var.environment}/vpc/terraform.tfstate"
    region  = var.default_region
  }
}

