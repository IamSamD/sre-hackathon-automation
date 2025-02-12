data "template_file" "container_definition" {
  template = file("${path.module}/container_definitions.json.tpl")
  vars = {
    aws_ecr_url               = var.aws_ecr_url
    tag                       = var.container_image_version
    cloudwatch_log_group_name = var.cloudwatch_log_group_name
    cloudwatch_log_prefix     = var.cloudwatch_log_prefix
    aws_region                = var.aws_region
  }
}

resource "aws_ecs_cluster_capacity_providers" "automation" {
  cluster_name = aws_ecs_cluster.automation.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "automation" {
  family                   = "automation"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.container_definition.rendered

  tags = var.default_tags
}

resource "aws_security_group" "ecs" {
  name_prefix = "automation-ecs-sg-"
  vpc_id      = aws_vpc.automation.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.default_tags
}

resource "aws_ecs_service" "automation" {
  name            = "automation"
  cluster         = aws_ecs_cluster.automation.id
  task_definition = aws_ecs_task_definition.automation.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private.id]
    security_groups = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.automation.arn
    container_name   = "automation-api"
    container_port   = 8080
  }

  tags = var.default_tags
}
