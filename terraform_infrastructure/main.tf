provider "aws" {
  region  = "eu-west-2"
  version = "~> 2.60.0"
  // assume_role {
  //   role_arn = var.role_arn
  // }
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.main_address_space
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.module_common_tags
}

resource "aws_default_security_group" "main_vpc_default_sg" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    local.module_common_tags,
    {
      "Name" = "${local.common_name_prefix}_Default-SG"
    },
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    local.public_vpc_resource_tags,
    {
      "Name" = "${local.common_name_prefix}_Internet-Gateway"
    },
  )
}

