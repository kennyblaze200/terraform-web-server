# Deployment Activity: `03-data-sources`

## Status: ✅ Deployed — ⚠️ Not Yet Destroyed

## Goal

Learn what **data sources** are and why they're important — querying AWS for existing infrastructure instead of hardcoding values.

## What Are Data Sources?

Data sources are Terraform's **read-only queries** to AWS. They discover information without creating any resources (no cost).

## The 7 Data Sources Deployed

| #   | Data Source                                                               | What It Discovered                                | Real-World Use                                                             |
| --- | ------------------------------------------------------------------------- | ------------------------------------------------- | -------------------------------------------------------------------------- |
| 1   | [`aws_caller_identity`](../../chapter-3/03-data-sources/main.tf:10)       | Account: `582381606543`, User: `vscode`           | Tags every resource with the account ID to prevent cross-account accidents |
| 2   | [`aws_region`](../../chapter-3/03-data-sources/main.tf:15)                | Region: `us-east-1`                               | Ensures code works in any region without hardcoding                        |
| 3   | [`aws_availability_zones`](../../chapter-3/03-data-sources/main.tf:20-28) | 5 AZs: `us-east-1a/b/c/d/f`                       | Excludes `us-east-1e` (no t3.micro support)                                |
| 4   | [`aws_ami`](../../chapter-3/03-data-sources/main.tf:33-46)                | `ami-02fd066b86800f60c` (Ubuntu jammy 2026-05-21) | Always uses the latest patched AMI — security best practice                |
| 5   | [`aws_vpc`](../../chapter-3/03-data-sources/main.tf:51-53)                | Default VPC                                       | No need to ask networking team for VPC ID                                  |
| 6   | [`aws_subnets`](../../chapter-3/03-data-sources/main.tf:58-67)            | All default subnet IDs                            | Multi-AZ deployment without hardcoding subnet IDs                          |
| 7   | [`aws_subnet` (for_each)](../../chapter-3/03-data-sources/main.tf:70-73)  | Per-subnet details (AZ, CIDR, public IP)          | Fine-grained subnet inspection                                             |

## Real-World Scenarios Solved

### 1. "The AMI went out of date" — Security Patch Automation

**Without data sources:** You hardcode `ami-02fd066b86800f60c`. When a critical CVE patch is released, you manually find the new AMI and update every file.

**With data sources:** `data.aws_ami.ubuntu` with `most_recent = true` always fetches the latest patched image. Every `terraform apply` is automatically secure.

### 2. "Which account am I in?" — Multi-Account Safety

**Without data sources:** Engineers accidentally run `terraform apply` against the production account because they forgot to switch profiles.

**With data sources:** Every resource is tagged with `Discovered:Account = 582381606543`. You always know which account received the deployment.

### 3. "us-east-1e doesn't support t3.micro" — AZ Filtering

**Without data sources:** You hardcode all 6 AZs. Deployment fails intermittently in `us-east-1e`.

**With data sources:** Explicitly filter out problematic AZs. Only healthy AZs are used.

## Resources Created

| Resource                           | ID / Name                  | Notes                                     |
| ---------------------------------- | -------------------------- | ----------------------------------------- |
| `data.aws_caller_identity.current` | `582381606543`             | Account discovered (no cost)              |
| `data.aws_ami.ubuntu`              | `ami-02fd066b86800f60c`    | Latest Ubuntu 22.04 discovered            |
| `data.aws_vpc.default`             | `vpc-01ed88066b160dcbe`    | Default VPC discovered                    |
| `aws_security_group.web`           | `chapter3-data-sources-sg` | Uses discovered VPC ID                    |
| `aws_instance.web`                 | `t3.micro`                 | Uses discovered AMI + account/region tags |

## Key Takeaway

> **Data sources let Terraform ask AWS "what's the current state?" instead of assuming — making your code always use the right AMI, VPC, and subnets without manual updates.**

## ⚠️ Action Required

`03-data-sources` is still running. Destroy it with:

```bash
cd /d C:\Users\T490\Documents\modulo-vault\terraform-aws-modules\chapter-3\03-data-sources
terraform destroy -auto-approve
```
