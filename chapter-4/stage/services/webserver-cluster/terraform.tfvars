# ──────────────────────────────────────────────────────────────────────────────
# Stage Webserver Cluster Configuration
# ──────────────────────────────────────────────────────────────────────────────

cluster_name  = "webserver-stage"
instance_type = "t3.micro"
server_port   = 80
min_size      = 2
max_size      = 5
