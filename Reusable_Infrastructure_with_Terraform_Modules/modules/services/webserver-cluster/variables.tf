# ----------------------------
# Variables
# ----------------------------
variable "server_port" {
  description = "Port for web server"
  type        = number
  default     = 8080
}

variable "instance_type" {
  description = "EC2 instance type for web server"
  type        = string
  default     = "t2.micro"
}

variable "min_size" {
  description = "Minimum size of ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of ec2 instances in the ASG"
  type        = number
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
  default     = "webserver-cluster"
}

variable "db_remote_state_bucket" {
  description = "S3 bucket name for remote state"
  type        = string
}

variable "db_remote_state_key" {
  description = "S3 key for remote state"
  type        = string
}