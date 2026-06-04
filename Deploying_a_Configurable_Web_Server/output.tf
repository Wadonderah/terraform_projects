output "public_ip" {
    value = aws_instance.wadoh.public_ip
    description = "Public IP of the instance"
  
}