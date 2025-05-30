terraform {
  backend "s3" {
    bucket = "ci-cd-terra-tfstate"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "web_sg" {
  description = "Allow HTTP traffic"

  ingress {
    description = "HTTP"
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
}

resource "aws_instance" "webapp" {
  ami                    = "ami-04169656fea786776" # Ubuntu 22.04 (us-east-1)
  instance_type          = "t2.micro"
  key_name               = "KPI_LAB_KEY"            # ім’я існуючого SSH-ключа
  user_data              = file("init.sh")
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "Terraform-WebApp"
  }
}

output "instance_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.webapp.public_ip
}