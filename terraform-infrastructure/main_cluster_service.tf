locals {
  is_services_tag_name_an_image_digest = length(regexall(".*sha256.*", var.services_docker_image_tag_name)) > 0
  services_tag_name                    = local.is_services_tag_name_an_image_digest ? "@${var.services_docker_image_tag_name}" : ":${var.services_docker_image_tag_name}"
}

resource "aws_ecs_task_definition" "ips_servs_task_def" {
  family                   = "ips-servs-tf"
  memory                   = "8192"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "4096"
  task_role_arn            = data.aws_iam_role.ecsTaskExecutionRole.arn
  execution_role_arn       = data.aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions = templatefile("${path.module}/service-task-def.json",
    {
      db_name        = var.db_name,
      db_server      = "${aws_db_instance.default.address}"
      db_user_name   = var.db_user_name,
      db_password    = var.db_password,
      log_group_name = local.services_log_group_name
      services_image = "${var.ecr_repo}/ips-services${local.services_tag_name}"
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

resource "aws_security_group_rule" "servs_sg_ingress_from_internal_lb" {
  from_port = 0
  protocol  = -1
  to_port   = 0
  type      = "ingress"
  // traffic from:
  source_security_group_id = aws_security_group.ips_internal_lb_sg.id

  // rules associated with security group:
  security_group_id = aws_security_group.ips_servs_sg.id
}

resource "aws_security_group_rule" "servs_sg_ingress_from_nat" {
  from_port = 0
  protocol  = -1
  to_port   = 0
  type      = "ingress"
  // traffic from:
  source_security_group_id = aws_security_group.natsg.id

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

//data "aws_security_group" "peered_db" {
//  vpc_id = data.aws_vpc.acceptor.id
//
//  filter {
//    name   = "tag:FilterKey"
//    values = ["*DB-Security-Group"]
//  }
//}
//
//resource "aws_security_group_rule" "ingress-into-db-group-sg-rule" {
//  type              = "ingress"
//  description       = "Allow MYSQL Traffic bettween services sg and peered db sg"
//  security_group_id = data.aws_security_group.peered_db.id
//
//  from_port                = 3306
//  to_port                  = 3306
//  protocol                 = "tcp"
//  source_security_group_id = aws_security_group.ips_servs_sg.id
//
//  depends_on = [aws_vpc_peering_connection.default]
//}

resource "aws_security_group_rule" "ingress-into-db-group-sg-rule" {
  type              = "ingress"
  description       = "Allow MYSQL Traffic bettween services sg and peered db sg"
  security_group_id = aws_security_group.db-sg.id

  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ips_servs_sg.id
}