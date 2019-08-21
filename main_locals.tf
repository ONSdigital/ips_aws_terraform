locals {
  common_name_prefix = aws_vpc.main_vpc.tags["Name"]
  module_common_tags = {
    "Name" = var.common_name
  }
  bastion_ingress_cidr      = "${var.bastion_ingress_ip}/32"
  private_vpc_resource_tags = merge(
    local.module_common_tags,
    {
      "Visibility" = "Private"
      "CreatedIn"  = "vpc-module/vpc_private_subnets"
    },
  )
  public_vpc_resource_tags = merge(
    local.module_common_tags,
    {
      "Visibility" = "Public"
      "CreatedIn"  = "vpc-module/vpc_public_subnets"
    },
  )
}

