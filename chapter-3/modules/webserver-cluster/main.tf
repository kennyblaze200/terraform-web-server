# ------------------------------------------------------------------------------
# MODULE: webserver-cluster
# Extracted from chapter-2/ — a reusable Auto Scaling Group + ALB module.
#
# IMPORTANT: This module does NOT contain a provider configuration.
# Providers are inherited from the calling root module.
# ------------------------------------------------------------------------------

# ──────────────────────────────────────────────────────────────────────────────
# SECURITY GROUPS
# ──────────────────────────────────────────────────────────────────────────────

# Security group for the EC2 instances — allows traffic on the web server port
resource "aws_security_group" "instance" {
  name_prefix = "${var.cluster_name}-instance-sg-"
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

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-instance-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for the ALB — allows HTTP traffic from the internet
resource "aws_security_group" "alb" {
  name_prefix = "${var.cluster_name}-alb-sg-"
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

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-alb-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# LAUNCH TEMPLATE — defines what each EC2 instance looks like
# ──────────────────────────────────────────────────────────────────────────────
resource "aws_launch_template" "example" {
  name_prefix   = "${var.cluster_name}-lt-"
  image_id      = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.instance.id]

  # Bootstrap script: install Apache and write a unique greeting
  user_data = base64encode(templatefile("${path.module}/user_data.tftpl", {
    cluster_name = var.cluster_name
    server_port  = var.server_port
  }))

  # Creates the new template before destroying the old one (zero-downtime updates)
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-launch-template"
  })
}

# ──────────────────────────────────────────────────────────────────────────────
# AUTO SCALING GROUP — automatically maintains desired instance count
# ──────────────────────────────────────────────────────────────────────────────
resource "aws_autoscaling_group" "example" {
  name = "${var.cluster_name}-asg"

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.subnet_ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# APPLICATION LOAD BALANCER (ALB) — single entry point for traffic
# ──────────────────────────────────────────────────────────────────────────────
resource "aws_lb" "example" {
  name               = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.alb.id]

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-alb"
  })
}

# ──────────────────────────────────────────────────────────────────────────────
# LISTENER — defines what traffic the ALB accepts
# ──────────────────────────────────────────────────────────────────────────────
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

# ──────────────────────────────────────────────────────────────────────────────
# TARGET GROUP — logical group of instances that receive traffic
# ──────────────────────────────────────────────────────────────────────────────
resource "aws_lb_target_group" "asg" {
  name     = "${var.cluster_name}-tg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-target-group"
  })
}

# ──────────────────────────────────────────────────────────────────────────────
# LISTENER RULE — forward all requests (path /*) to the target group
# ──────────────────────────────────────────────────────────────────────────────
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
