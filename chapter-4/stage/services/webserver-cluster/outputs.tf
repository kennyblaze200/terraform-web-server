output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.webserver_cluster.alb_dns_name
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = module.webserver_cluster.alb_arn
}

output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = module.webserver_cluster.asg_name
}

output "instance_sg_id" {
  description = "The ID of the instance security group"
  value       = module.webserver_cluster.instance_security_group_id
}
