variable "main_address_space" {
  default = "10.30.0.0/16"
}

variable "public_subnet_count" {
  default = 2
}

variable "private_subnet_count" {
  default = 2
}

variable "cidr_block_all" {
  default = "0.0.0.0/0"
}

variable "arn_certificate" {}

# Mandataory inputs
variable "bastion_ingress_ip" {
}

variable "deploy_key_name" {
}

variable "common_name" {
}
variable "db_name" {}
variable "db_server" {}
variable "db_user_name" {}
variable "db_password" {}

variable "peered_vpc_name" {
  description = "Name of the peered VPC with a DB"
}

variable "ecr_repo" {
  default = "000704438865.dkr.ecr.eu-west-2.amazonaws.com"
}

variable "ui_docker_image_tag_name" {
  default = "latest"
}

variable "services_docker_image_tag_name" {
  default = "latest"
}

