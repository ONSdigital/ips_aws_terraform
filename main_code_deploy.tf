resource "aws_codedeploy_app" "ui_code_deploy" {
  compute_platform = "ECS"
  name             = "${local.common_name_prefix}-UI-Code-Deploy"
}

resource "aws_codedeploy_deployment_group" "ips_code_deploy_group" {
  app_name               = "${aws_codedeploy_app.ui_code_deploy.name}"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "${local.common_name_prefix}-IPS-CD-Group"
  service_role_arn       = "arn:aws:iam::014669633018:role/ecsCodeDeployRole"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 45
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ips_cluster.name
    service_name = aws_ecs_service.ui_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.ips_lb_listener.arn]
      }

      target_group {
        name = aws_lb_target_group.blue.name
      }

      target_group {
        name = aws_lb_target_group.green.name
      }
    }
  }
}

resource "aws_lb_target_group" "green" {
  name                 = "${local.common_name_prefix}-Green-TG"
  port                 = "5000"
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.main_vpc.id
  deregistration_delay = 10

  health_check {
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 6
    matcher             = "200,301,302"
  }
}

resource "aws_lb_target_group" "blue" {
  name                 = "${local.common_name_prefix}-Blue-TG"
  port                 = "5000"
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.main_vpc.id
  deregistration_delay = 10

  health_check {
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 6
    matcher             = "200,301,302"
  }
}

resource "aws_lb" "ips_cd_lb" {
  name               = "${local.common_name_prefix}-ips-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ips_lb_sg.id]
  subnets            = aws_subnet.public_subnets.*.id
}
