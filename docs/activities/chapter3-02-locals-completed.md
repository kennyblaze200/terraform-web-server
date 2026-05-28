# Deployment Activity: `02-locals`

## Status: ✅ Completed (Pending Destroy)

## Goal

Learn Terraform's **`locals {}`** block — compute values once, reuse everywhere.

## Files Deployed

| File                                                           | Purpose                                                                                       |
| -------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| [`providers.tf`](../../chapter-3/02-locals/providers.tf)       | AWS provider config                                                                           |
| [`variables.tf`](../../chapter-3/02-locals/variables.tf)       | `environment`, `project_name`, `instance_type`, `custom_ami_id`, `base_tags`, `enable_backup` |
| [`main.tf`](../../chapter-3/02-locals/main.tf)                 | Data source (AMI) + 6 locals + SG (dynamic ingress) + EC2 + null_resource                     |
| [`outputs.tf`](../../chapter-3/02-locals/outputs.tf)           | Exposes all computed local values                                                             |
| [`user_data.tftpl`](../../chapter-3/02-locals/user_data.tftpl) | HTML template showing environment, hostname, feature flags                                    |

## Resources Created

| Resource                         | ID / Name               | Notes                                                    |
| -------------------------------- | ----------------------- | -------------------------------------------------------- |
| `data.aws_ami.ubuntu`            | `ami-02fd066b86800f60c` | Discovered via `ubuntu-jammy-22.04` filter (fixed)       |
| `aws_security_group.web`         | `sg-0b04c069ad590f998`  | Named `terraform-in-depth-learning-web-sg` (from locals) |
| `aws_instance.web`               | `i-072e4534fa88210d4`   | t3.micro at `98.92.216.133`                              |
| `null_resource.metadata_printer` | —                       | Printed prefix, tag count, env                           |

## Local Values Demonstrated

| Local           | Computed Value                  | Pattern                       |
| --------------- | ------------------------------- | ----------------------------- |
| `name_prefix`   | `"terraform-in-depth-learning"` | `"${var.project}-${var.env}"` |
| `ami_id`        | `ami-02fd066b86800f60c`         | Ternary: custom or discovered |
| `common_tags`   | 5 tags merged                   | `merge(base + computed)`      |
| `backup_tags`   | `Backup: disabled`              | Ternary: `enable_backup ?`    |
| `all_tags`      | 7 tags total                    | `merge(common + backup)`      |
| `ingress_rules` | HTTP(80) + SSH(22)              | Environment-aware rules       |
| `user_data`     | HTML page with env info         | `templatefile()`              |

## Key Takeaway

`locals {}` eliminates repetition. If a value is used more than once or requires computation, put it in a local.

## Next

Proceeding to **`03-data-sources/`** then will destroy all.
