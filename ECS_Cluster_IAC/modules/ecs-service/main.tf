
resource "aws_security_group" "ecs_tasks" {
  name   = "${var.name}-sg-task"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = var.container_port
    to_port     = var.container_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_cloudwatch_log_group" "cwlg" {
  name = "/ecs/${var.name}-task"

  tags = {
    Name        = "${var.name}-task"
    
  }
}

resource "aws_ecs_task_definition" "main_td" {
  family                   = "${var.name}-taskdefinition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "arn:aws:iam::224679164727:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::224679164727:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([{
    name      = "${var.name}-container"
    image     = "${var.container_image}"
    essential = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.container_port
      hostPort      = var.container_port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.cwlg.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    }
  }])
}


resource "aws_ecs_service" "main_ecsservice" {
  name                = "${var.name}-service"
  cluster             = var.ecs_cluster
  task_definition     = aws_ecs_task_definition.main_td.arn
  desired_count       = 1
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.public_subnets_ids
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
