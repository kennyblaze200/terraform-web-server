# ──────────────────────────────────────────────────────────────────────────────
# Stage MySQL Configuration
# ──────────────────────────────────────────────────────────────────────────────

db_name       = "stagedb"
db_user       = "admin"
db_password   = "StagePassword123!"   # CHANGE before applying to real environments
instance_class = "db.t3.micro"
allocated_storage = 20
engine_version    = "8.0"
skip_final_snapshot = true
