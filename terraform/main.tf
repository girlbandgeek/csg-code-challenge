provider "aws" {
  region = "us-east-2"
}

# provision Ubuntu 20.04 instance
resource "aws_instance" "csg-test" {
  ami				= "ami-06c4532923d4ba1ec"
  instance_type			= "t2.micro"
  vpc_security_group_ids	= [aws_security_group.instance.id]

# Add ssh public key for access
  user_data = <<-EOF
              #!/bin/bash
              echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjsr1B++pu22BpGNXMwc+7F+Jsscz1/dwS4Mu2fwBTaexRpnHKAbw98LYhUh8xZSp3G0U1kL/UNaj4K0W/0NIM3EnAeR+vuaFmoGHSxu9ob+kn8ZQf8mw0JRM3BFROg/ooObtwDRKrZDtnxZr/itOB220gWjkNxLG7PaWSwlM8c4Y5L758ojWvLub/nE45Wpkg2sQW1lPwfi0gV1YFW1y7VU7z24KjOCzh9LZcLmb29jBwjcHVW7thR9THsHmXdOzvUEH/ynow74+SVXNsLuEcVqQfKAvIlpUvvmLDeEC+QRdDN2Y5UJ+xoUJNXtpzZg4tKxyMrxJv9AC6HO5qxkpd daniel@Daniels-MacBook-Pro.local" >> /home/ubuntu/.ssh/authorized_keys
              EOF

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

# Output the public IP address
output "public_ip" {
  value	= aws_instance.csg-test.public_ip
  description = "The public IP of the instance"
}
