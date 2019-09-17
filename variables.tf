//module "vpc" {
//  source = "../modules/vpc-module"
//
//  main_address_space   = "${var.main_address_space}"
//  cidr_block_all       = "${var.cidr_block_all}"
//  private_subnet_count = "${var.private_subnet_count}"
//  public_subnet_count  = "${var.public_subnet_count}"
//  deploy_key_name      = "${var.deploy_key_name}"
//  bastion_ingress_cidr = "${var.bastion_ingress_cidr}"
//
//  parent_tags = "${merge(module.common_tags.tags, map("Name", "${var.common_name}"))}"
//}

variable "main_address_space" {
  default = "10.0.0.0/16"
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

# Mandataory inputs
variable "bastion_ingress_ip" {
}

variable "deploy_key_name" {
}

variable "aws_access_key" {
}

variable "aws_secret_key" {
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
  default = "014669633018.dkr.ecr.eu-west-2.amazonaws.com"
}

variable "ui_docker_image_tag_name" {
  default = "latest"
}

variable "services_docker_image_tag_name" {
  default = "latest"
}