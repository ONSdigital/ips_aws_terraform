resource "aws_security_group" "ips_lb_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  description = "The security group associated with the application load balancer."
  tags = merge(
    local.module_common_tags,
    {
      "Name" = "${local.common_name_prefix}_lb-SG"
    },
  )
}

resource "aws_security_group_rule" "ips_lb_sg_ingress_80" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.ips_lb_sg.id
  to_port = 80
  type = "ingress"
  cidr_blocks = [local.bastion_ingress_cidr]
}

resource "aws_security_group_rule" "ips_lb_sg_egress_all" {
  type = "egress"
  from_port = 0
  protocol = -1
  to_port = 0
  source_security_group_id = aws_security_group.ui_sg.id

  security_group_id = aws_security_group.ips_lb_sg.id
}

resource "aws_lb" "ips_lb" {
  name               = "ips-lb-tf-2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ips_lb_sg.id]
  subnets            = aws_subnet.public_subnets.*.id
}

resource "aws_lb_target_group" "ips_tg" {
  name                 = "ips-tg-tf"
  port                 = "5000"
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.main_vpc.id
  deregistration_delay = 10

  health_check {
    protocol            = "HTTP"
    port                = 5000
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 6
    matcher             = "200,301,302"
  }
}

resource "aws_lb_listener" "ips_lb_listener" {
  load_balancer_arn = aws_lb.ips_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ips_tg.arn
  }
}

