# Real-World Explanation: Variables, Locals, Data Sources, Outputs & Modules

> **Reference**: This explains what the Chapter 3 infrastructure patterns solve in real-world terms — the business problem, the analogy for each concept, and how companies actually use these patterns at scale.
> **Related**: [`chapter-3/01-advanced-variables/`](chapter-3/01-advanced-variables/), [`chapter-3/02-locals/`](chapter-3/02-locals/), [`chapter-3/03-data-sources/`](chapter-3/03-data-sources/), [`chapter-3/04-outputs/`](chapter-3/04-outputs/), [`chapter-3/modules/webserver-cluster/`](chapter-3/modules/webserver-cluster/), [`chapter-3/05-module-consumer/`](chapter-3/05-module-consumer/), [`chapter-3/06-remote-state/`](chapter-3/06-remote-state/)

---

## The Core Problem It Solves

**Without these patterns**: You copy-paste the same Terraform code for every project. You hardcode values everywhere. When you need to change something (like an AMI or instance type), you hunt through dozens of files. Each environment (dev, staging, prod) has slightly different code that diverges over time.

**With these patterns**: You write infrastructure code **once**, wrap it in a **reusable module**, and call it from different environments with different variable files. Changes propagate everywhere. New teams consume your infrastructure like a library.

---

## What Each Sub-Project Does in the Real World

| Sub-Project                                                          | Real-World Analogy                                                                  | What It Actually Does                                                                                          |
| -------------------------------------------------------------------- | ----------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| [`01-advanced-variables/`](chapter-3/01-advanced-variables/)         | A **job application form** with specific requirements (must be 18+, valid ID, etc.) | Type constraints, validation rules, and sensitivity controls that catch configuration errors before deployment |
| [`02-locals/`](chapter-3/02-locals/)                                 | A **cheat sheet** of computed values you reference repeatedly                       | Computes reusable values (names, tags, AMIs) so you don't repeat complex expressions                           |
| [`03-data-sources/`](chapter-3/03-data-sources/)                     | **Asking AWS** "what's available?" before building                                  | Queries AWS for existing resources: latest AMI, available AZs, account info, VPCs                              |
| [`04-outputs/`](chapter-3/04-outputs/)                               | A **shipping manifest** with detailed info about what was built                     | Exposes structured, sensitive-safe, validated information about deployed resources                             |
| [`modules/webserver-cluster/`](chapter-3/modules/webserver-cluster/) | An **IKEA instruction booklet** for building a web cluster                          | A standardized, versioned blueprint for deploying ASG + ALB anywhere                                           |
| [`05-module-consumer/`](chapter-3/05-module-consumer/)               | **Following the IKEA instructions** with your own room measurements                 | Calls the module with your specific VPC, subnets, and sizing needs                                             |
| [`06-remote-state/`](chapter-3/06-remote-state/)                     | A **phone book** that tells you other teams' infrastructure addresses               | Reads outputs from another Terraform project's state to enable cross-team communication                        |

---

## Real-World Scenario: A Company with Multiple Environments

Imagine **Modulo** has grown. You now need to run the web cluster in **three environments**: development, staging, and production.

### Without Modules (the painful way)

You'd have three copies of the same code:

- `dev/main.tf` — ASG + ALB + all resources
- `staging/main.tf` — copy-pasted with different values
- `prod/main.tf` — copy-pasted with different values

When you fix a bug in the dev security group, you need to manually fix it in staging and prod too. Someone forgets → **production outage**.

### With Modules (the modern way)

```
modules/webserver-cluster/     ← ONE source of truth
├── main.tf                    ← ASG + ALB, written once
├── variables.tf               ← cluster_name, ami, vpc_id, etc.
└── outputs.tf                 ← alb_dns_name, asg_name

environments/
├── dev/
│   ├── main.tf                ← module "webserver_cluster" { source = "../modules/webserver-cluster" ... }
│   └── terraform.tfvars       ← min_size = 1, max_size = 2
├── staging/
│   ├── main.tf                ← same module call
│   └── terraform.tfvars       ← min_size = 2, max_size = 5
└── prod/
    ├── main.tf                ← same module call
    └── terraform.tfvars       ← min_size = 3, max_size = 20
```

Fix a bug in the module → all three environments get the fix. That's the power of modules.

---

## How Companies Actually Use These Patterns

| Company     | Pattern Used       | How                                                                                                                                    |
| ----------- | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| **Netflix** | Modules            | Has a `base-networking` module used by every team. VPC/subnets are never configured manually.                                          |
| **Spotify** | Data Sources       | Dynamically discovers the latest AMI IDs for each region using `data.aws_ami`, so deployments always use the most secure base image.   |
| **Airbnb**  | Locals + Variables | Uses `locals` to compute naming conventions and tagging strategies that comply with their cloud governance policy.                     |
| **Stripe**  | Sensitive Outputs  | Marks database passwords and API keys as `sensitive = true` so they never appear in CI/CD logs.                                        |
| **Shopify** | Remote State       | The networking team manages VPCs in one project; the app team uses `terraform_remote_state` to discover subnet IDs without hardcoding. |
| **Uber**    | Multi-env Modules  | One module called with different `terraform.tfvars` for each city/region they operate in.                                              |

---

## The Specific Business Problems We Solve

### Problem 1: "The AMI Was Outdated"

**Symptom**: A security scan flagged that your EC2 instances are running an Ubuntu image with known vulnerabilities.

**Fix with data sources**: Instead of hardcoding `ami-02fd066b86800f60c`, use [`data.aws_ami.ubuntu`](chapter-3/03-data-sources/main.tf:36-47) with `most_recent = true`. Every `terraform apply` automatically uses the latest patched AMI.

**Real-world parallel**: Companies like **Netflix** automate AMI updates — when a new patched AMI is published, Terraform automatically replaces old instances during the next deployment.

### Problem 2: "Someone Deployed an Invalid Instance Type"

**Symptom**: A junior engineer accidentally set `instance_type = "m5.24xlarge"` in production. The monthly AWS bill increased by $6,000 before anyone noticed.

**Fix with validation**: Add a [`validation` block](chapter-3/01-advanced-variables/variables.tf:13-18) that restricts instance types to only those approved for your account.

**Real-world parallel**: **Stripe** and **Twilio** use Terraform validation extensively to prevent expensive misconfigurations. Some companies run `terraform plan` through automated policy checks (like Sentinel or OPA) that reject non-compliant configurations.

### Problem 3: "The Password Leaked in CI/CD Logs"

**Symptom**: A database password appeared in plain text in GitHub Actions logs because `terraform output` displayed it.

**Fix with sensitive outputs**: Mark the output as [`sensitive = true`](chapter-3/04-outputs/outputs.tf:40-44). Terraform hides it from CLI output and logs. Downstream tools (like Vault or AWS Secrets Manager) can still access it programmatically.

**Real-world parallel**: **Hashicorp** themselves recommend marking all database passwords, API keys, and private keys as `sensitive`. This is a SOC 2 compliance requirement for many companies.

### Problem 4: "Dev, Staging, and Prod Diverged"

**Symptom**: The staging environment hasn't been updated in 6 months. It still uses an outdated launch template. Production got a new feature but staging didn't. Deployments break mysteriously.

**Fix with modules**: Extract the entire cluster into a [reusable module](chapter-3/modules/webserver-cluster/). Each environment calls the same module with different variables. A fix to the module is automatically applied everywhere.

**Real-world parallel**: **Airbnb** famously consolidated 40+ different infrastructure configurations into a set of reusable Terraform modules. Deployment time dropped from days to minutes.

---

## File-by-File Deep Dive

### [`01-advanced-variables/variables.tf`](chapter-3/01-advanced-variables/variables.tf) — "The Application Form with Rules"

```hcl
variable "instance_type" {
  type = string
  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "Must be free-tier eligible."
  }
}
```

**Real-world analogy**: This is like a job application that says "You must be at least 18 years old." If someone applies who's 16, the form rejects them immediately — no need for a manager to manually check.

**Why this matters**: In a large organization, dozens of people might run `terraform apply`. Validation catches mistakes early.

---

### [`02-locals/main.tf`](chapter-3/02-locals/main.tf) — "The Cheat Sheet"

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.base_tags, {
    Name = "${local.name_prefix}-server"
  })
}
```

**Real-world analogy**: This is like having a whiteboard in the office with commonly used phone numbers — instead of looking them up every time, you glance at the whiteboard.

**Why this matters**: Without locals, you'd write `${var.project_name}-${var.environment}-server` everywhere. If the naming convention changes, you update 50 places instead of 1.

---

### [`03-data-sources/main.tf`](chapter-3/03-data-sources/main.tf) — "The Building Inspector"

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
}
```

**Real-world analogy**: Before renovating a room, you check the building's blueprints (data source) to find where the load-bearing walls are. You don't guess — you look it up.

**Why this matters**: Hardcoding AMI IDs is like hardcoding a phone number. It works today, but tomorrow the number might change. Data sources always give you the current answer.

---

### [`modules/webserver-cluster/main.tf`](chapter-3/modules/webserver-cluster/main.tf) — "The IKEA Instructions"

```hcl
resource "aws_autoscaling_group" "example" {
  min_size = var.min_size
  max_size = var.max_size
  # ...
}
```

**Real-world analogy**: This is like an IKEA instruction booklet for a bookshelf. It doesn't know if you're building it in a small apartment or a large house — but it tells you exactly what to do regardless. You (the consumer) provide the measurements (variables).

**Why this matters**: A module is **versioned infrastructure**. You can update the module, increment the version, and every team that uses it gets the update when they're ready.

---

### [`05-module-consumer/main.tf`](chapter-3/05-module-consumer/main.tf) — "Building the Bookshelf in Your Living Room"

```hcl
module "webserver_cluster" {
  source = "../modules/webserver-cluster"
  cluster_name = var.cluster_name
  min_size     = var.min_size
  vpc_id       = data.aws_vpc.default.id
}
```

**Real-world analogy**: You have the IKEA instructions (module). You measure your living room (data sources), pick the wood color (variables), and build the bookshelf. Next year, you move to a bigger house — you use the same instructions with new measurements.

**Why this matters**: The same module can deploy to dev (2 instances, t3.micro) and prod (20 instances, m5.large) — just different variable files.

---

### [`06-remote-state/main.tf`](chapter-3/06-remote-state/main.tf) — "The Shared Whiteboard"

```hcl
data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key    = var.remote_state_key
  }
}
```

**Real-world analogy**: The networking team has a whiteboard that says "The ALB DNS name is X." The app team reads that whiteboard instead of asking "Hey, what's the ALB DNS name?" every time.

**Why this matters**: In microservices architectures, different teams manage different parts of infrastructure. `terraform_remote_state` lets them discover each other's outputs without manual coordination.

---

## What Makes This "Real-World" vs "Toy Project"

| Aspect                  | Chapter 2 (Basic)          | Chapter 3 (Production Patterns)                                         |
| ----------------------- | -------------------------- | ----------------------------------------------------------------------- |
| **Variables**           | Simple strings and numbers | Type-constrained, validated, sensitive, nullable, objects, tuples, maps |
| **Naming**              | Hardcoded in each resource | Computed via `locals` with environment prefixes                         |
| **AMIs**                | Hardcoded AMI ID           | Dynamically discovered via `data.aws_ami`                               |
| **Code Reuse**          | Copy-paste to new envs     | Single module called from multiple environments                         |
| **Information Sharing** | Manual documentation       | `terraform_remote_state` for automated discovery                        |
| **Error Prevention**    | Discovered at `apply` time | Validation blocks catch errors at `plan` time                           |
| **Outputs**             | Simple text values         | Structured, sensitive, precondition-validated outputs                   |

---

## The Business Value

**Before these patterns** (what most companies do initially):

- Infrastructure code is duplicated across environments
- Configuration drift between dev, staging, and prod
- Secrets accidentally exposed in logs
- AMI updates require manual tracking
- Each new project starts from scratch

**After these patterns** (what this chapter demonstrates):

- One module, many environments — DRY infrastructure
- Validation prevents costly misconfigurations
- Sensitive values stay hidden
- Data sources ensure you always use the latest secure images
- Remote state enables cross-team infrastructure discovery
- New projects start with `module "my_standard_stack" { source = "..." }`

**Real-world ROI example**:

> A SaaS company had 12 microservices, each with its own copy-pasted Terraform. Deploying a new service took **1 week** (copy, modify, test, deploy). After extracting shared infrastructure into modules, deploying a new service took **2 hours**. A critical security patch to the base AMI that used to take 3 days to roll out now takes 30 minutes — update the module version, run `terraform apply` in each environment.
