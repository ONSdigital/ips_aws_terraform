resource "aws_ecs_cluster" "ips_cluster" {
  name = "${local.common_name_prefix}-cluster-tf"
}

resource "aws_ecs_task_definition" "ui_task_def" {
  family                   = "ips-ui-tf"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  task_role_arn            = "ecsTaskExecutionRole"
  execution_role_arn       = "ecsTaskExecutionRole"
  container_definitions    = <<EOF
[
  {
    "name": "ips-ui-tf",
    "image": "014669633018.dkr.ecr.eu-west-2.amazonaws.com/ips-ui:latest",
    "memory": null,
    "memoryReservation": null,
    "essential": true,
    "environment": [
        {
          "name": "API_HOST",
          "value": "ips-services.ips-service"
        },
        {
          "name": "API_PORT",
          "value": "5000"
        },
        {
          "name": "API_PROTOCOL",
          "value": "http"
        },
        {
          "name": "FLASK_APP",
          "value": "ips"
        },
        {
          "name": "FLASK_ENV",
          "value": "development"
        },
        {
          "name": "UI_FLASK_APP",
          "value": "ips"
        }
      ],
    "portMappings": [
        {
          "hostPort": 5000,
          "protocol": "tcp",
          "containerPort": 5000
        }
      ]
  }
]
EOF

  //  volume {
  //    name      = "service-storage"
  //    host_path = "/ecs/service-storage"
  //  }
}

resource "aws_ecs_task_definition" "services_task_def" {
  family                = "ips-services-td-tf"
  memory                = "1024"
  container_definitions = <<EOF
[
  {
  "name": "ips-services",
  "image": "014669633018.dkr.ecr.eu-west-2.amazonaws.com/ips-services:2",
  "cpu": 0,
  "memory": null,
  "memoryReservation": null,
  "essential": true,
  "environment": [
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
  "portMappings": [
    {
      "hostPort": 5000,
      "protocol": "tcp",
      "containerPort": 5000
    }
  ]
}
]
EOF


  volume {
    name      = "service-storage-tf"
    host_path = "/ecs/service-storage"
  }
}

resource "aws_ecs_service" "ui_service" {
  name            = "ips-ui-tf"
  cluster         = aws_ecs_cluster.ips_cluster.id
  task_definition = aws_ecs_task_definition.ui_task_def.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private_subnets.*.id
    security_groups  = [aws_security_group.ui_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ips_tg.arn
    container_name   = "ips-ui-tf"
    container_port   = 5000
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

  ingress {
    from_port       = 0
    protocol        = -1
    to_port         = 0
    security_groups = [aws_security_group.ips_lb_sg.id]
  }

  egress {
    from_port = 0
    protocol  = -1
    to_port   = 0
  }
}

