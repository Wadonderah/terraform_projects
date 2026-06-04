############################
# VARIABLES
############################

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources into"
  default     = "us-east-2"
}

variable "name_prefix" {
  type        = string
  description = "Prefix used to name all resources"
  default     = "wadoh"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  type        = number
  description = "Number of public subnets to create (one per AZ)"
  default     = 2
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to spread subnets across"
  default     = ["us-east-2a", "us-east-2b"]
}

variable "server_port" {
  type        = number
  description = "Port the web server listens on"
  default     = 8080
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the launch configuration"
  default     = "t2.micro"
}

variable "alb_listener_port" {
  type        = number
  description = "Port the ALB listens on for inbound HTTP traffic"
  default     = 80
}

variable "health_check_path" {
  type        = string
  description = "HTTP path used by the ALB target group health check"
  default     = "/"
}

variable "asg_min_size" {
  type        = number
  description = "Minimum number of instances in the Auto Scaling Group"
  default     = 2
}

variable "asg_max_size" {
  type        = number
  description = "Maximum number of instances in the Auto Scaling Group"
  default     = 5
}

variable "user_data_message" {
  type        = string
  description = "Message written to index.html on each EC2 instance"
  default     = "Hello from Wadoh ASG"
}
