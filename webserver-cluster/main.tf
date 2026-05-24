# ------------------------------------------------------------------------------
# DATA SOURCES
# Query AWS for existing infrastructure (no resources created, no cost)
# ------------------------------------------------------------------------------

# Discover the default VPC in our AWS account
data "aws_vpc" "default" {
  default = true
}

# Discover all subnets within the default VPC
# NOTE: Excluding us-east-1e because t3.micro is not available in that AZ
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}

# ------------------------------------------------------------------------------
# SECURITY GROUPS
# ------------------------------------------------------------------------------

# Security group for the EC2 instances — allows traffic on the web server port
resource "aws_security_group" "instance" {
  name        = var.instance_security_group_name
  description = "Security group for EC2 instances in the ASG"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound internet access so instances can download packages (apt-get)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.instance_security_group_name
  }
}

# Security group for the ALB — allows HTTP traffic from the internet
resource "aws_security_group" "alb" {
  name        = var.alb_security_group_name
  description = "Security group for the Application Load Balancer"

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
    Name = var.alb_security_group_name
  }
}

# ------------------------------------------------------------------------------
# LAUNCH TEMPLATE
# A template that defines what each EC2 instance looks like
# NOTE: Launch Templates are the modern replacement for Launch Configurations.
# AWS deprecated Launch Configurations in 2023.
# ------------------------------------------------------------------------------

resource "aws_launch_template" "example" {
  name_prefix   = "terraform-asg-example-"
  image_id      = "ami-02fd066b86800f60c" # Ubuntu 22.04 LTS in us-east-1
  instance_type = "t3.micro"              # Free-tier eligible

  vpc_security_group_ids = [aws_security_group.instance.id]

  # Bootstrap script: install Apache and write a unique greeting
  # NOTE: user_data runs as root on Ubuntu, so sudo is not needed
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "Hello from instance $(hostname -f)" > /var/www/html/index.html
  EOF
  )

  # Creates the new template before destroying the old one (zero-downtime updates)
  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# AUTO SCALING GROUP
# Automatically maintains a desired number of EC2 instances
# ------------------------------------------------------------------------------

resource "aws_autoscaling_group" "example" {
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

# ------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER (ALB)
# Single entry point that distributes traffic across instances
# ------------------------------------------------------------------------------

resource "aws_lb" "example" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

# Listener: defines what traffic the ALB accepts and the default response
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

# Target group: a logical group of instances that receive traffic
resource "aws_lb_target_group" "asg" {
  name     = var.alb_name
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener rule: forward all requests (path /*) to the target group
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}
