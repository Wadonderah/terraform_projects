resource "aws_instance" "wadoh" {
  ami                    = "ami-078f95be0757084a3"
  instance_type          = "t2.micro"

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.wadoh.id]

  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello, Sir!!" > /var/www/html/index.html
EOF

  tags = {
    Name = "wadoh"
  }
}


resource "aws_security_group" "wadoh" {
  name = "wadoh_sg"
  description = "Allow HTTP inbound traffic"
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
  
  tags = {
    Name = "wadoh_sg"
  }

}