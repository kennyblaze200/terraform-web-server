# Deployment Activity: `01-advanced-variables`

## Status: ✅ Completed & Destroyed

## Goal

Learn Terraform's **advanced variable features**: type constraints, validation blocks, sensitive values, nullable, objects, tuples, sets, and maps of objects.

## Files Deployed

| File                                                                         | Purpose                                                         |
| ---------------------------------------------------------------------------- | --------------------------------------------------------------- |
| [`providers.tf`](../../chapter-3/01-advanced-variables/providers.tf)         | AWS provider config (`us-east-1`, profile `terraform-in-depth`) |
| [`variables.tf`](../../chapter-3/01-advanced-variables/variables.tf)         | 11 variable declarations demonstrating different type patterns  |
| [`main.tf`](../../chapter-3/01-advanced-variables/main.tf)                   | Security group (dynamic ingress), EC2 instance, null_resource   |
| [`outputs.tf`](../../chapter-3/01-advanced-variables/outputs.tf)             | Instance info + sensitive hash output                           |
| [`terraform.tfvars`](../../chapter-3/01-advanced-variables/terraform.tfvars) | Variable overrides for the deployment                           |
| [`user_data.tftpl`](../../chapter-3/01-advanced-variables/user_data.tftpl)   | Apache bootstrap template with conditional logic                |

## Resources Created

| Resource                       | Type           | What It Demonstrated                                        |
| ------------------------------ | -------------- | ----------------------------------------------------------- |
| `aws_security_group.web`       | Security Group | `dynamic` ingress block from `map(object)` variable         |
| `aws_instance.web`             | EC2 (t3.micro) | Configuration from `object{}` variable; validation on ports |
| `null_resource.sensitive_demo` | Null Resource  | Password stored as SHA256 hash, never plain text            |

## Variable Patterns Demonstrated

| #   | Pattern                     | Variable Name                | What We Learned                                   |
| --- | --------------------------- | ---------------------------- | ------------------------------------------------- |
| 1   | `string` + `validation {}`  | `instance_type`              | Rejects non-free-tier instance types at plan time |
| 2   | `number` + `validation {}`  | `root_volume_size`           | Range check (8GB–100GB)                           |
| 3   | `bool`                      | `enable_detailed_monitoring` | Simple on/off toggle for features                 |
| 4   | `list(string)` + validation | `security_group_cidr_blocks` | Validates each element is a real CIDR             |
| 5   | `map(string)`               | `tags`                       | Key-value pairs for resource labeling             |
| 6   | `object({...})`             | `web_server_config`          | Groups multiple settings into one variable        |
| 7   | `tuple([...])`              | `network_config`             | Fixed-position mixed types                        |
| 8   | `sensitive = true`          | `db_password`                | Prevents secret exposure in CLI/logs              |
| 9   | `nullable = true`           | `custom_user_data_script`    | Allows explicit null for conditional fallback     |
| 10  | `set(string)`               | `availability_zones`         | Unordered unique values                           |
| 11  | `map(object({...}))`        | `security_group_rules`       | Data-driven resource creation with `dynamic`      |

## Commands Executed

```bash
terraform init
terraform plan            # Validated all variables pass constraints
terraform apply           # Created 3 resources successfully
terraform output          # Confirmed sensitive output is hidden
terraform destroy         # Cleaned up all AWS resources
```

## Key Observations

1. **Validation blocks work** — any attempt to use an invalid instance type (e.g., `m5.xlarge`) is **rejected at plan time** before any AWS API call
2. **Sensitive output behavior** — `terraform output` shows `(sensitive value)` instead of the actual hash, preventing accidental secret leaks
3. **Dynamic blocks** — the `map(object)` variable drives security group rule creation without copying code
4. **No sensitive data exposed** in this document — all passwords/hashes are referenced only by their variable names

## Ready For

Next project: **`02-locals/`** — Local values for DRY code
