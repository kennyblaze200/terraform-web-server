# Deployment Activity: `04-outputs`

## Status: ✅ Completed & Destroyed

## Goal
Learn Terraform's **output patterns** — how to expose infrastructure information to other systems (CI/CD, monitoring, billing) in a safe, structured way.

## 8 Output Patterns Demonstrated

| # | Pattern | Output Name | Real-World Value |
|---|---|---|---|
| 1 | **Basic** | `instance_id`, `instance_public_ip`, `instance_public_dns` | CI/CD pipeline reads these to know where to deploy |
| 2 | **Sensitive** | `api_key_preview` — shows `(sensitive value)` | Prevents secrets from leaking into build logs |
| 3 | **Sensitive (derived)** | `api_key_sha256` — Terraform 1.8+ dataflow tracking | Any output derived from a sensitive variable must also be marked sensitive |
| 4 | **Structured Object** | `instance_details` — returns 8 fields in one map | One output instead of 8 — consuming systems get all info in one call |
| 5 | **For Expression** | `security_group_ingress_summary` — transforms raw rules | Converts raw AWS data into a clean, reportable format |
| 6 | **Conditional** | `environment_info` — changes based on `var.environment` | Monitoring systems alert if prod doesn't have correct backup policy |
| 7 | **Precondition** | `validated_instance_id` — checks value is non-empty | Catches failed resource creation before downstream systems receive bad data |
| 8 | **Map Transformation** | `resource_tags_map` — merges tags from all resources | Billing team uses this for cost allocation across teams |

## Bug Fix Applied

During deployment, Terraform 1.8+ returned:
```
Error: Output refers to sensitive values
  on outputs.tf line 40: output "api_key_sha256"
```

**Root cause:** Terraform 1.8+ enforces **dataflow tracking** — any output derived from a sensitive variable must also be marked `sensitive = true`, even if it's a one-way hash.

**Fix:** Added `sensitive = true` to `api_key_sha256` output in [`outputs.tf:45`](../../chapter-3/04-outputs/outputs.tf:45).

## Resources Created (Then Destroyed)

| Resource | Notes |
|---|---|
| `aws_security_group.web` | SG with HTTP + HTTPS ingress |
| `aws_instance.web` | t3.micro with Apache |

## Key Takeaway
> **Outputs are your infrastructure's API — without them, other systems have no way to discover what you deployed.**

## Next
Proceeding to **`05-module-consumer/`** — consuming the reusable `webserver-cluster` module.
