############################
# AMI LOOKUP (latest Amazon Linux 2)
############################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

############################
# VPC
############################
resource "aws_vpc" "wadoh" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

############################
# INTERNET GATEWAY
############################
resource "aws_internet_gateway" "wadoh" {
  vpc_id = aws_vpc.wadoh.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

############################
# PUBLIC SUBNETS
############################
resource "aws_subnet" "wadoh" {
  count = var.subnet_count

  vpc_id                  = aws_vpc.wadoh.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-subnet-${count.index}"
  }
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

  tags = {
    Name = "${var.name_prefix}-rt"
  }
}

############################
# ROUTE TABLE ASSOCIATIONS
############################
resource "aws_route_table_association" "wadoh" {
  count = var.subnet_count

  subnet_id      = aws_subnet.wadoh[count.index].id
  route_table_id = aws_route_table.wadoh.id
}

############################
# SECURITY GROUP - ALB
############################
resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.wadoh.id
  name   = "${var.name_prefix}-alb-sg"

  ingress {
    from_port   = var.alb_listener_port
    to_port     = var.alb_listener_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

############################
# SECURITY GROUP - EC2
############################
resource "aws_security_group" "ec2" {
  vpc_id = aws_vpc.wadoh.id
  name   = "${var.name_prefix}-ec2-sg"

  ingress {
    from_port       = var.server_port
    to_port         = var.server_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-ec2-sg"
  }
}

############################
# TARGET GROUP
############################
resource "aws_lb_target_group" "wadoh" {
  name     = "${var.name_prefix}-tg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.wadoh.id

  health_check {
    path     = var.health_check_path
    protocol = "HTTP"
    matcher  = "200"
  }

  tags = {
    Name = "${var.name_prefix}-tg"
  }
}

############################
# APPLICATION LOAD BALANCER
############################
resource "aws_lb" "wadoh" {
  name               = "${var.name_prefix}-alb"
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb.id]
  subnets         = aws_subnet.wadoh[*].id

  tags = {
    Name = "${var.name_prefix}-alb"
  }
}

############################
# LISTENER
############################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.wadoh.arn
  port              = var.alb_listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wadoh.arn
  }
}

############################
# LAUNCH TEMPLATE
############################
resource "aws_launch_template" "wadoh" {
  name_prefix   = "${var.name_prefix}-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "${var.user_data_message}" > index.html
    nohup python3 -m http.server ${var.server_port} &
  EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-lt"
  }
}

############################
# AUTO SCALING GROUP
############################
resource "aws_autoscaling_group" "wadoh" {
  vpc_zone_identifier = aws_subnet.wadoh[*].id
  target_group_arns   = [aws_lb_target_group.wadoh.arn]
  health_check_type   = "ELB"
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size

  launch_template {
    id      = aws_launch_template.wadoh.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.name_prefix
    propagate_at_launch = true
  }
}
