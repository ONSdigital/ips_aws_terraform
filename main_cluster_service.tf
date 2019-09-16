resource "aws_ecs_task_definition" "ips_servs_task_def" {
  family                   = "ips-servs-tf"
  memory                   = "4096"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  task_role_arn            = "ecsTaskExecutionRole"
  execution_role_arn       = "ecsTaskExecutionRole"
  container_definitions = templatefile("${path.module}/service-task-def.json",
    {
      db_name        = var.db_name,
      db_server      = var.db_server,
      db_user_name   = var.db_user_name,
      db_password    = var.db_password,
      log_group_name = local.services_log_group_name
  })
}

resource "aws_ecs_service" "ips_servs_service" {
  name            = "${local.common_name_prefix}-ips-servs-tf"
  cluster         = aws_ecs_cluster.ips_cluster.id
  task_definition = aws_ecs_task_definition.ips_servs_task_def.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private_subnets.*.id
    security_groups  = [aws_security_group.ips_servs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ips_services_internal_facing_tg.arn
    container_name   = "ips-services"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.ips_services_internal_facing_lb_listener, aws_lb_target_group.ips_services_internal_facing_tg]
}

resource "aws_security_group" "ips_servs_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  description = "The security group associated with all the ui"
  tags = merge(
    local.public_vpc_resource_tags,
    {
      "Name" = "${local.common_name_prefix}_servs_tf"
    },
  )
}

resource "aws_security_group_rule" "servs_sg_ingress_from_ui" {
  from_port = 0
  protocol  = -1
  to_port   = 0
  type      = "ingress"
  // traffic from:
  source_security_group_id = aws_security_group.ui_sg.id

  // rules associated with security group:
  security_group_id = aws_security_group.ips_servs_sg.id
}

resource "aws_security_group_rule" "servs_sg_ingress_self" {
  from_port = 0
  protocol  = -1
  to_port   = 0
  type      = "ingress"
  self      = true

  // rules associated with security group:
  security_group_id = aws_security_group.ips_servs_sg.id
}
resource "aws_security_group_rule" "servs_sg_egress_all" {
  from_port   = 0
  protocol    = -1
  to_port     = 0
  type        = "egress"
  cidr_blocks = [var.cidr_block_all]

  security_group_id = aws_security_group.ips_servs_sg.id
}

