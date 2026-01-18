data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH from my IP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    description = "Outbound to internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_iam_role" "cw_agent_role" {
  name = "${var.project_name}-cw-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_agent_attach" {
  role       = aws_iam_role.cw_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "cw_agent_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.cw_agent_role.name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "monitoring_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.cw_agent_profile.name
  key_name = var.key_name
  tags = {
    Name = "${var.project_name}-ec2"
  }
}

resource "aws_cloudwatch_log_group" "syslog" {
  name              = "/aws/ec2/${var.project_name}/syslog"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "authlog" {
  name              = "/aws/ec2/${var.project_name}/auth"
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "cpu_low_idle" {
  alarm_name          = "${var.project_name}-cpu-low-idle"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "cpu_usage_idle"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 40

  alarm_description = "Alarm when CPU idle is low (busy CPU) for 5 minutes."

  dimensions = {
    host = aws_instance.monitoring_ec2.private_dns
    cpu  = "cpu-total"
  }
}
