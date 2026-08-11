output "monitoring_instance_id" {
  description = "ID of the monitoring server"
  value       = aws_instance.monitoring.id
}

output "monitoring_public_ip" {
  description = "Public IP of the monitoring server"
  value       = aws_instance.monitoring.public_ip
}

output "monitoring_private_ip" {
  description = "Private IP of the monitoring server"
  value       = aws_instance.monitoring.private_ip
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.application.dns_name
}

output "application_asg_name" {
  description = "Name of the application Auto Scaling group"
  value       = aws_autoscaling_group.application.name
}