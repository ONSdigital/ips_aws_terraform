terraform {
  source = ".//."
}

locals {
  environment = get_env("TF_ENV", "sandbox")
}

inputs = {
  environment = local.environment
}

remote_state {
  backend = "s3"

  config = {
    bucket         = "ips-terraform-state-${local.environment}"
    key            = "${local.environment}-bootstrap/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "ips-terraform-locks-${local.environment}"
  }
}
