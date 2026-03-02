output "instance_public_ip" {
  description = "Elastic IP - Add this to your NoIP subdomain"
  value       = aws_eip.fusionpact_eip.public_ip
}

output "domain_name" {
  description = "Your configured domain name"
  value       = var.domain_name
}

output "frontend_url" {
  description = "Frontend URL (HTTPS)"
  value       = "https://${var.domain_name}"
}

output "backend_url" {
  description = "Backend API URL"
  value       = "https://${var.domain_name}:8000"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "https://${var.domain_name}:3000"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "https://${var.domain_name}:9090"
}

output "direct_ip_access" {
  description = "Direct IP access (before SSL certificate is ready)"
  value = {
    frontend   = "http://${aws_eip.fusionpact_eip.public_ip}"
    backend    = "http://${aws_eip.fusionpact_eip.public_ip}:8000"
    grafana    = "http://${aws_eip.fusionpact_eip.public_ip}:3000"
    prometheus = "http://${aws_eip.fusionpact_eip.public_ip}:9090"
  }
}


