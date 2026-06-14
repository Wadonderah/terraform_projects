
# ----------------------------
# Terraform Backend (REMOTE STATE)
# Stores state in S3 so other stacks (web) can read it
# ----------------------------
terraform {
  backend "s3" {
    bucket = "wadoh-terraform-state"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"
  }
}

# ----------------------------
# AWS Provider configuration
# ----------------------------
provider "aws" {
  region = "us-east-2"
}

# ----------------------------
# RDS MySQL Database
# ----------------------------
resource "aws_db_instance" "name" {
  identifier_prefix = "wadohdb"

  engine            = "mysql"
  engine_version = "8.4.8"
  allocated_storage = 10
  instance_class    = "db.t3.micro"

  db_name = "wadohdb"

  # Credentials come from variables.tf
  username = var.db_username
  password = var.db_password

  skip_final_snapshot = true
}