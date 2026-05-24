output "public_ip" {
  value       = aws_instance.app.public_ip
  description = "The public IP address of the web server"
}

output "public_dns" {
  value       = aws_instance.app.public_dns
  description = "The public DNS name of the web server"
}

output "instance_id" {
  value       = aws_instance.app.id
  description = "The ID of the EC2 instance"
}
