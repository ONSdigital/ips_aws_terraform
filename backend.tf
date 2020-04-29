terraform {
  backend "s3" {
    bucket = "socsur-ips-aws-b-services-terraform-state"
    key = "project-name/terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "socsur-ips-aws-b-services-terraform-locks"
    encrypt = true
  }
}
