locals {
  is_ui_tag_name_an_image_digest = length(regexall(".*sha256.*", var.ui_docker_image_tag_name)) > 0
  ui_tag_name                    = local.is_ui_tag_name_an_image_digest ? "@${var.ui_docker_image_tag_name}" : ":${var.ui_docker_image_tag_name}"
}

resource "aws_ecs_task_definition" "ui_task_def" {
  family                   = "ips-ui-tf"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  task_role_arn            = "ecsTaskExecutionRole"
  execution_role_arn       = "ecsTaskExecutionRole"
  container_definitions = templatefile("${path.module}/ui-task-def.json",
    {
      services_alb_dns = aws_lb.ips_services_internal_facing_lb.dns_name,
      log_group_name   = local.ui_log_group_name
      ui_image         = "${var.ecr_repo}/ips-ui${local.ui_tag_name}"
  })
}

resource "aws_ecs_service" "ui_service" {
  name            = "${local.common_name_prefix}-ips_ui_tf"
  cluster         = aws_ecs_cluster.ips_cluster.id
  task_definition = aws_ecs_task_definition.ui_task_def.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private_subnets.*.id
    security_groups  = [aws_security_group.ui_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = "ips-ui-tf"
    container_port   = 5000
  }

    deployment_controller {
      type = "CODE_DEPLOY"
    }

  depends_on = [aws_lb_listener.ips_lb_listener]
}

resource "aws_security_group" "ui_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  description = "The security group associated with all the ui"
  tags = merge(
    local.public_vpc_resource_tags,
    {
      "Name" = "${local.common_name_prefix}_ui_tf"
    },
  )
}

resource "aws_security_group_rule" "ui_sg_ingress_from_lb" {
  from_port                = 0
  protocol                 = -1
  to_port                  = 0
  type                     = "ingress"
  source_security_group_id = aws_security_group.ips_lb_sg.id

  security_group_id = aws_security_group.ui_sg.id
}

resource "aws_security_group_rule" "ui_sg_egress_all" {
  from_port   = 0
  protocol    = -1
  to_port     = 0
  type        = "egress"
  cidr_blocks = [var.cidr_block_all]

  security_group_id = aws_security_group.ui_sg.id
}

