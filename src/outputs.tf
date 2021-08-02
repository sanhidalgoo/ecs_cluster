output "alb_dns" {
  value = aws_lb.ecs-lb.dns_name
}