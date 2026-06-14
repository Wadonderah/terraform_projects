# ----------------------------
# AWS Provider
# ----------------------------
provider "aws" {
  region = "us-east-2"
}

# ----------------------------
# Remote state (DB outputs)
# ----------------------------
data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = "wadoh-terraform-state"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"
  }
}

# ----------------------------
# Get default VPC subnets (FIX for your error)
# ----------------------------
data "aws_subnets" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# ----------------------------
# Security Group
# ----------------------------
resource "aws_security_group" "instance" {
  name = "web-sg"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

# ----------------------------
# Launch Template
# ----------------------------
resource "aws_launch_template" "web" {
  name_prefix   = "web-template-"
  image_id      = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  }))
}

# ----------------------------
# Auto Scaling Group (FIXED)
# ----------------------------
resource "aws_autoscaling_group" "web" {
  vpc_zone_identifier = data.aws_subnets.default.ids

  desired_capacity = 1
  max_size         = 2
  min_size         = 1

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "web-server"
    propagate_at_launch = true
  }
}