
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
# SUBNETS
############################

resource "aws_subnet" "wadoh_a" {
  vpc_id            = aws_vpc.wadoh.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "wadoh-subnet-a"
  }
}

resource "aws_subnet" "wadoh_b" {
  vpc_id            = aws_vpc.wadoh.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "wadoh-subnet-b"
  }
}

############################
# SECURITY GROUP
############################

resource "aws_security_group" "wadoh" {
  name        = "wadoh-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.wadoh.id

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
# AMAZON LINUX 2023 AMI
############################

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

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
echo "Hello, Sir!!" > index.html
nohup busybox httpd -f -p ${var.server_port} &
EOF
  )

  tags = {
    Name = "wadoh-launch-template"
  }
}

############################
# AUTO SCALING GROUP
############################

resource "aws_autoscaling_group" "wadoh" {
  min_size = 2
  max_size = 10

  vpc_zone_identifier = [
    aws_subnet.wadoh_a.id,
    aws_subnet.wadoh_b.id
  ]

  launch_template {
    id      = aws_launch_template.wadoh.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "wadoh-asg-instance"
    propagate_at_launch = true
  }
}