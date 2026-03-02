variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04"
  type        = string
  default     = "ami-0e9085e60087ce171"  # Ubuntu 22.04 LTS for eu-west-1
}

variable "key_pair_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "grafana_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "database_url" {
  description = "Database URL"
  type        = string
  default     = "sqlite:///./data/app.db"
}

variable "domain_name" {
  description = "Your NoIP domain name (e.g., myapp.ddns.net)"
  type        = string
}

variable "ssl_email" {
  description = "Email for Let's Encrypt SSL certificate notifications"
  type        = string
}