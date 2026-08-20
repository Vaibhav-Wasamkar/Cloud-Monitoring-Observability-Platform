output "application_url" {
  description = "URL of the application"
  value       = "http://${aws_lb.application.dns_name}"
}

output "prometheus_url" {
  description = "URL of the Prometheus server"
  value       = "http://${aws_instance.monitoring.public_ip}:9090"
}

output "grafana_url" {
  description = "URL of the Grafana server"
  value       = "http://${aws_instance.monitoring.public_ip}:3000"
}

output "alertmanager_url" {
  description = "URL of the Alertmanager server"
  value       = "http://${aws_instance.monitoring.public_ip}:9093"
}