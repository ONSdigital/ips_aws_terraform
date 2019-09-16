resource "aws_security_group" "ips_internal_lb_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  description = "The security group associated with the services inernal facing load balancer."
  tags = merge(
    local.module_common_tags,
    {
      "Name" = "${local.common_name_prefix}-internal-facing-lb",
      "app"  = "ips"
    },
  )
}

resource "aws_security_group_rule" "ips_internal_lb_sg_ingress_from_ui" {
  from_port = 0
  protocol  = -1
  to_port   = 0
  type      = "ingress"
  // traffic from:
  source_security_group_id = aws_security_group.ui_sg.id

  // rules associated with security group:
  security_group_id = aws_security_group.ips_internal_lb_sg.id
}

resource "aws_security_group_rule" "ips_internal_lb_sg_ingress_from_self" {
  from_port = 0
  protocol  = -1
  to_port   = 0
  type      = "ingress"
  self      = true

  // rules associated with security group:
  security_group_id = aws_security_group.ips_internal_lb_sg.id
}

resource "aws_security_group_rule" "ips_internal_lb_sg_egress_all" {
  from_port   = 0
  protocol    = -1
  to_port     = 0
  type        = "egress"
  cidr_blocks = [var.cidr_block_all]

  security_group_id = aws_security_group.ips_internal_lb_sg.id
}

resource "aws_lb" "ips_services_internal_facing_lb" {
  name               = "${local.common_name_prefix}-services-int-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ips_internal_lb_sg.id]
  subnets            = aws_subnet.private_subnets.*.id

  tags = {
    Name        = "ips-services-internal-lb",
    app         = "ips",
    description = "ips services internal facing lb"
  }
}

resource "aws_lb_target_group" "ips_services_internal_facing_tg" {
  name                 = "${local.common_name_prefix}-services-int-tg"
  port                 = "5000"
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.main_vpc.id
  deregistration_delay = 10

  health_check {
    protocol            = "HTTP"
    path                = "/health_check"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_listener" "ips_services_internal_facing_lb_listener" {
  load_balancer_arn = aws_lb.ips_services_internal_facing_lb.arn
  port              = "5000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ips_services_internal_facing_tg.arn
  }
}