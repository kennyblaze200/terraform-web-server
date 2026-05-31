# ------------------------------------------------------------------------------
# MODULE: webserver-cluster — Outputs
# ------------------------------------------------------------------------------

output "alb_dns_name" {
  description = "The domain name of the load balancer"
  value       = aws_lb.example.dns_name
}

output "alb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.example.arn
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb.example.zone_id
}

output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.example.name
}

output "asg_arn" {
  description = "The ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.example.arn
}

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = aws_launch_template.example.id
}

output "instance_security_group_id" {
  description = "The ID of the EC2 instance security group"
  value       = aws_security_group.instance.id
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.asg.arn
}

output "listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}
