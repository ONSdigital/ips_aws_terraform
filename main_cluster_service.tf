resource "aws_ecs_task_definition" "ips_servs_task_def" {
  family                   = "ips-servs-tf"
  memory                   = "4096"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  task_role_arn            = "ecsTaskExecutionRole"
  execution_role_arn       = "ecsTaskExecutionRole"
  container_definitions    = <<EOF
  [
    {
    "name": "ips-services",
    "image": "014669633018.dkr.ecr.eu-west-2.amazonaws.com/ips-services:2",
    "cpu": 0,
    "memory": null,
    "memoryReservation": null,
    "essential": true,
    "environment":
    [
      {
        "name": "DB_NAME",
        "value": "ips"
      },
      {
redacted  # Replace, using a regex
        "value": "qsB9m9IwKG1CaC5Uu2qqmjUMaHGLXA"
      },
      {
        "name": "DB_SERVER",
        "value": "ips-db.cyjaepzpx1tk.eu-west-2.rds.amazonaws.com"
      },
      {
        "name": "DB_USER_NAME",
        "value": "admin"
      }
    ],
    "portMappings":
    [
      {
        "hostPort": 5000,
        "protocol": "tcp",
        "containerPort": 5000
        }
      ]
    }
  ]
  EOF
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

//  TODO: Needs some kind of Service Discovery...
//  service discovery endpoint = "servs_task_def.local"
//  service discovery name = "servs_task"
//  DNS record type = "A"
//  contain... = null
//  TTL = "60"
//  namespace = "local (PRIVATE)"

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
  protocol = -1
  to_port = 0
  type = "ingress"
  // traffic from:
  source_security_group_id = aws_security_group.ui_sg.id

  // rules associated with security group:
  security_group_id = aws_security_group.ips_servs_sg.id
}

resource "aws_security_group_rule" "servs_sg_egress_all" {
  from_port = 0
  protocol = -1
  to_port = 0
  type = "egress"
  cidr_blocks = [var.cidr_block_all]

  security_group_id = aws_security_group.ips_servs_sg.id
}

