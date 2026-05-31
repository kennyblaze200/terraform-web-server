# ──────────────────────────────────────────────────────────────────────────────
# Production Webserver Cluster Configuration
# ──────────────────────────────────────────────────────────────────────────────

cluster_name  = "webserver-prod"
instance_type = "t3.medium"     # Larger instances for production
server_port   = 80
min_size      = 5               # Always keep 5 instances running
max_size      = 20              # Can scale up to 20 during traffic spikes
