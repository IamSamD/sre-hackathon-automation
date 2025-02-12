resource "aws_security_group" "alb" {
  name_prefix = "automation-alb-sg-"
  vpc_id      = aws_vpc.automation.id

  # Allow traffic from internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.default_tags
}

resource "aws_lb" "automation" {
  name               = "automation-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  subnet_mapping {
    subnet_id = aws_subnet.public_az1.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.public_az2.id
  }

  tags = var.default_tags
}

resource "aws_lb_target_group" "automation" {
  name        = "automation-target-group"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.automation.id

  health_check {
    path = "/_status/healthz"
  }

  tags = var.default_tags
}

resource "aws_alb_listener" "automation_http" {
  load_balancer_arn = aws_lb.automation.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.automation.arn
  }
}

# resource "aws_lb_listener" "automation_https" {
#   load_balancer_arn = aws_lb.automation.arn
#   port              = 443
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.automation.arn
#   }
# }
