resource "aws_ecs_cluster" "ips_cluster" {
  name = "${local.common_name_prefix}-cluster-tf"
}
