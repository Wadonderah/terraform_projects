output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.wadoh.dns_name
}

output "ami_id_used" {
  description = "The AMI ID resolved by the data source (latest Amazon Linux 2)"
  value       = data.aws_ami.amazon_linux.id
}
