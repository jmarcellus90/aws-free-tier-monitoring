variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-east-2"
}

variable "project_name" {
  type        = string
  description = "Project naming prefix"
  default     = "aws-monitoring-lab"
}

variable "ssh_cidr" {
  type        = string
  description = "Your public IP in CIDR format for SSH access (example: 1.2.3.4/32)"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type (Free Tier eligible)"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name for SSH"
  default     = "aws-monitoring-key"
}
