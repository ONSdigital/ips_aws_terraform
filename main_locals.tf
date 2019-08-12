
locals {
  common_name_prefix        = "${aws_vpc.main_vpc.tags["Name"]}"
  module_common_tags        = "${map( "Name", var.common_name)}"
  private_vpc_resource_tags = "${merge(local.module_common_tags, map("Visibility", "Private", "CreatedIn", "vpc-module/vpc_private_subnets"))}"
  public_vpc_resource_tags  = "${merge(local.module_common_tags, map("Visibility", "Public", "CreatedIn", "vpc-module/vpc_public_subnets"))}"
}
