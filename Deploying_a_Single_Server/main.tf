resource "aws_instance" "wadoh" {
  ami           = "ami-078f95be0757084a3"
  instance_type = "t2.micro"

  tags = {
    Name = "wadoh"
  }

}