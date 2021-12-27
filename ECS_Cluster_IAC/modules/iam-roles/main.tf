
resource "aws_iam_role" "ecsRole" {
  name = "ecsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy" "AmazonEC2ContainerServicePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_policy_attachment" "AmazonEC2ContainerServiceRole" {
  name       = "AmazonEC2ContainerServiceRole"
  roles      = [aws_iam_role.ecsRole.name]
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerServicePolicy.arn
}

// IAM Role for task execution role(Allow the ECS Tasks to download images from ECR & Allow the ECS tasks to upload logs to CloudWatch)

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy" "AmazonECSTaskExecutionPolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy_attachment" "AmazonECSTaskExecutionRolePolicy" {
  name       = "AmazonECSTaskExecutionRolePolicy"
  roles      = [aws_iam_role.ecsTaskExecutionRole.name]
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionPolicy.arn
}