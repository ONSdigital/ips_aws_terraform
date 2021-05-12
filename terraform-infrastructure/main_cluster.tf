resource "aws_ecs_cluster" "ips_cluster" {
  name = "${local.common_name_prefix}-Cluster"
}

variable "cluster_components" {
  type = map
  default = {
    ui_component       = "ui"
    services_component = "service"
  }
}

resource "aws_cloudwatch_log_group" "this" {
  count = length(var.cluster_components)
  name  = "/ecs/${local.common_name_prefix}/${values(var.cluster_components)[count.index]}"
}

locals {
  services_log_group_name = "/ecs/${local.common_name_prefix}/${var.cluster_components.services_component}"
  ui_log_group_name       = "/ecs/${local.common_name_prefix}/${var.cluster_components["ui_component"]}"
}

// data "aws_iam_role" "ecsTaskExecutionRole" {
//   name = "ecsTaskExecutionRole"
// }
