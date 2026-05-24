resource "aws_instance" "app" {
  instance_type     = "t3.micro"
  availability_zone = "us-east-1a"
  ami               = "ami-02fd066b86800f60c" # Ubuntu 22.04 LTS in us-east-1 (latest)

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
  EOF

  tags = {
    Name = "terraform-in-depth-lab"
  }
}
