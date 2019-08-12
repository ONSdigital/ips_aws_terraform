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
variable "bastion_ingress_cidr" {}
variable "deploy_key_name" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "common_name" {}
