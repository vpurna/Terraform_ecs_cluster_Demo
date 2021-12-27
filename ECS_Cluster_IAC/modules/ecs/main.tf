resource "aws_ecs_cluster" "cluster" {
  name = "grafana-app"

}

output "ecs-id" {
  value = aws_ecs_cluster.cluster.id
}
