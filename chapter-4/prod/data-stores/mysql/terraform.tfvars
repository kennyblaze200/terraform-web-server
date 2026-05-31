# ──────────────────────────────────────────────────────────────────────────────
# Production MySQL Configuration
# ──────────────────────────────────────────────────────────────────────────────

db_name       = "proddb"
db_user       = "admin"
db_password   = "ProdPassword456!"    # CHANGE before applying to real environments
instance_class = "db.t3.small"        # Larger for production
allocated_storage = 40                # Double the storage for production
engine_version    = "8.0"
skip_final_snapshot = true
