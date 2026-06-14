# ----------------------------
# Database username variable
# ----------------------------
variable "db_username" {
  description = "Database admin username"
  type        = string
}

# ----------------------------
# Database password variable
# ----------------------------
variable "db_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}