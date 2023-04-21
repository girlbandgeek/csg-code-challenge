provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "csg-test" {
  ami			= "ami-06c4532923d4ba1ec"
  instance_type		= "t2.micro"

  tags = {
    Name = "csg-test"
  }
}


