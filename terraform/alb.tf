resource "aws_lb" "application" {
  name               = "${var.project_name}-Application-ALB"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = aws_subnet.public[*].id

  tags = {
    Name = "${var.project_name}-Application-ALB"
  }
}

resource "aws_lb_target_group" "application" {
  name     = "${var.project_name}-Application-TG"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.monitoring.id

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project_name}-Application-TG"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.application.arn
      }
    }
  }
}