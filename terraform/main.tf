provider "aws" {
  region = "us-east-2"
}

# provision Ubuntu 20.04 instance
resource "aws_instance" "csg-test" {
  ami				= "ami-06c4532923d4ba1ec"
  instance_type			= "t2.micro"
  vpc_security_group_ids	= [aws_security_group.instance.id]

  tags = {
    Name = "csg-test"
  }
}

# Add security group with required ports
resource "aws_security_group" "instance" {
  name = "csg-test-instance"

  ingress {
    from_port	= 22
    to_port	= 22
    protocol	= "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port	= 443
    to_port	= 443
    protocol	= "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
