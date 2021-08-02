resource "aws_ecs_cluster" "web-cluster" {
  name               = var.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.pyxis-capacity-provider.name]
}

resource "aws_ecs_capacity_provider" "pyxis-capacity-provider" {
  name = "pyxis-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 85
    }
  }
}

resource "aws_ecs_task_definition" "pyxis-task-definition" {
  family                = "web-family"
  container_definitions = file("container-definitions/container-def.json")
  network_mode          = "bridge"
}

resource "aws_ecs_service" "service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.web-cluster.id
  task_definition = aws_ecs_task_definition.pyxis-task-definition.arn
  desired_count   = 7
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = "hello-pyxis"
    container_port   = 80
  }
  # Optional: Allow external changes without Terraform plan difference(for example ASG)
  # lifecycle {
  #   ignore_changes = [desired_count]
  # }
  launch_type = "EC2"
  depends_on  = [aws_lb_listener.web-listener]
}

# resource "aws_cloudwatch_log_group" "log_group" {
#   name = "/ecs/frontend-container"
# }