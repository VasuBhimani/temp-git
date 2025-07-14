provider "aws" {
  region = "us-east-1" # Change as needed
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 (for us-east-1)
  instance_type = "t2.micro"

  # Use default VPC subnet
  subnet_id = data.aws_subnet_ids.default.ids[0]

  # Get default VPC
  vpc_security_group_ids = [data.aws_security_group.default.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello from Terraform EC2" > /var/www/html/index.html
              EOF

  tags = {
    Name = "MyTerraformEC2"
  }
}

# Fetch default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch a subnet from default VPC
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Use the default security group
data "aws_security_group" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }

  vpc_id = data.aws_vpc.default.id
}
