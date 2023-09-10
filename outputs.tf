output "app_url" {
  value = aws_alb.application_load_balancer.dns_name # log the load balancer app URL
}
