resource "aws_instance" "wadoh" {
    ami           = "ami-0c6ac5f2fed2981b0"
    instance_type = "t2.micro"
  
}


resource "aws_instance" "wadoh-1" {
    ami           = "ami-0c6ac5f2fed2981b0"
     instance_type = terraform.workspace == "default" ? "t2.medium" : "t2.micro"
  
}