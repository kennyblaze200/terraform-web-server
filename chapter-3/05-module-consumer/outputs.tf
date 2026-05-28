# ------------------------------------------------------------------------------
# 05-module-consumer — outputs.tf
# Consumes module outputs using the module.<name>.<output> syntax
# ------------------------------------------------------------------------------

output "alb_dns_name" {
  description = "The DNS name of the ALB (from module output)"
  value       = module.webserver_cluster.alb_dns_name
}

output "alb_arn" {
  description = "The ARN of the ALB (from module output)"
  value       = module.webserver_cluster.alb_arn
}

output "asg_name" {
  description = "The name of the Auto Scaling Group (from module output)"
  value       = module.webserver_cluster.asg_name
}

output "instance_security_group_id" {
  description = "The ID of the instance security group (from module output)"
  value       = module.webserver_cluster.instance_security_group_id
}

output "module_source" {
  description = "The module source path used"
  value       = module.webserver_cluster.alb_dns_name != null ? "../modules/webserver-cluster" : "N/A"
}

output "module_demo_summary" {
  description = "Summary of module concepts demonstrated"
  value = {
    module_source       = "../modules/webserver-cluster (local path)"
    data_sources        = "aws_vpc.default, aws_subnets.default, aws_ami.ubuntu"
    module_inputs       = "cluster_name, ami, vpc_id, subnet_ids, instance_type, min_size, max_size, server_port, tags"
    module_outputs_used = "alb_dns_name, alb_arn, asg_name, instance_security_group_id"
    module_composition  = "Root module + custom module = final infrastructure"
  }
}
