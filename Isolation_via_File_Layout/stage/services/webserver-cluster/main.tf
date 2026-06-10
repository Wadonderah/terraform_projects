provider "aws" {
  region = "us-east-2"
}

############################
# VARIABLES
############################

variable "server_port" {
  description = "HTTP port"
  type        = number
  default     = 80
}

############################
# VPC
############################

resource "aws_vpc" "wadoh" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "wadoh-vpc"
  }
}

############################
# INTERNET GATEWAY
############################

resource "aws_internet_gateway" "wadoh" {
  vpc_id = aws_vpc.wadoh.id
}

############################
# ROUTE TABLE
############################

resource "aws_route_table" "wadoh" {
  vpc_id = aws_vpc.wadoh.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wadoh.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.wadoh_a.id
  route_table_id = aws_route_table.wadoh.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.wadoh_b.id
  route_table_id = aws_route_table.wadoh.id
}

############################
# SUBNETS (PUBLIC)
############################

resource "aws_subnet" "wadoh_a" {
  vpc_id                  = aws_vpc.wadoh.id
  cidr_block              = "10.0.1.0/24"
  availability_zone      = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "wadoh-subnet-a"
  }
}

resource "aws_subnet" "wadoh_b" {
  vpc_id                  = aws_vpc.wadoh.id
  cidr_block              = "10.0.2.0/24"
  availability_zone      = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "wadoh-subnet-b"
  }
}

############################
# SECURITY GROUP
############################

resource "aws_security_group" "wadoh" {
  name        = "wadoh-sg"
  vpc_id      = aws_vpc.wadoh.id
  description = "Allow HTTP traffic"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# AMI (Amazon Linux 2023)
############################

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

############################
# LAUNCH TEMPLATE
############################

resource "aws_launch_template" "wadoh" {
  name_prefix   = "wadoh-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.wadoh.id
  ]

  user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
dnf install -y httpd
systemctl start httpd
systemctl enable httpd

echo "Hello from Wadoh ASG" > /var/www/html/index.html
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "wadoh-instance"
    }
  }
}

############################
# AUTO SCALING GROUP
############################

resource "aws_autoscaling_group" "wadoh" {
  min_size         = 2
  max_size         = 5
  desired_capacity  = 2

  vpc_zone_identifier = [
    aws_subnet.wadoh_a.id,
    aws_subnet.wadoh_b.id
  ]

  launch_template {
    id      = aws_launch_template.wadoh.id
    version = "$Latest"
  }

  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "wadoh-asg-instance"
    propagate_at_launch = true
  }
}