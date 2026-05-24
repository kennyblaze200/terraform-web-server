resource "aws_security_group" "web" {
  name        = "web-server-sg"
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
    Name = "web-server-sg"
  }
}

resource "aws_instance" "app" {
  instance_type     = var.instance_type
  availability_zone = "us-east-1a"
  ami               = "ami-02fd066b86800f60c" # Ubuntu 22.04 LTS in us-east-1 (latest)

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
  EOF

  tags = {
    Name = var.instance_name
  }
}
