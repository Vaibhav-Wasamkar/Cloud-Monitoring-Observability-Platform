variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability Zones for the monitoring infrastructure"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair"
  type        = string
}

variable "repository_url" {
  description = "Public GitHub repository URL"
  type        = string
}

variable "webhook_secret_arn" {
  description = "ARN of the webhook secret in AWS Secrets Manager"
  type        = string
}