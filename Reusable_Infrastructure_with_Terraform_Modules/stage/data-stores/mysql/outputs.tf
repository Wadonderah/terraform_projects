# ----------------------------
# DB endpoint (used by web stack)
# ----------------------------
output "address" {
  value       = aws_db_instance.name.address
  description = "RDS endpoint"
}

# ----------------------------
# DB port (usually 3306)
# ----------------------------
output "port" {
  value       = aws_db_instance.name.port
  description = "Database port"
}