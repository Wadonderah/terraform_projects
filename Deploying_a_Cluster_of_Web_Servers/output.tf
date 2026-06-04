output "asg_name" {
  value = aws_autoscaling_group.wadoh.name
}

output "vpc_id" {
  value = aws_vpc.wadoh.id
}