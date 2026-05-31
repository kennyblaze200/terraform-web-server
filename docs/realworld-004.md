# Real-World Explanation: Module Composition & Multi-Environment Deployments

> **Reference**: This explains what Chapter 4's module composition pattern solves in real-world terms.
> **Related**: [`chapter-4/`](chapter-4/)

---

## The Core Problem It Solves

**Without module composition:** You have 3 environments (dev, staging, prod). Each needs a webserver and a database. You copy-paste the same infrastructure code 6 times (3 envs × 2 services). When you find a security bug in the dev webserver, you have to manually fix it in staging and prod. Someone forgets → **production outage**.

**With module composition:** You write two modules (webserver, database) once. Each environment calls them with different configuration files. Fix the module → fix all environments.

---

## Real-World Scenario: "The Startup That Scaled"

### The Problem

Imagine **Modulo** has grown to 50 microservices. Each service needs:
- A web cluster (ASG + ALB) 
- A database (RDS MySQL)

Without modules, this is 100 copy-pasted configurations. With modules, it's 2 modules called 50 times with different variables.

### The Analogy: Restaurant Kitchen

Think of modules like kitchen appliances:
- **Module** = The recipe book (how to make a dish)
- **Stage environment** = The practice kitchen (test the recipe)
- **Prod environment** = The main kitchen (serve customers)
- **Variables** = The ingredients (different for each dish)

You don't rewrite the recipe for each kitchen — you use the same recipe with different ingredients.

---

## How Real Companies Use This Pattern

| Company | How They Use Module Composition |
|---|---|
| **Netflix** | Has a `base-networking` module (VPC + subnets + NAT) and a `microservice` module (ECS + ALB + RDS). Every team composes these two modules for each service. |
| **Airbnb** | Built a library of 40+ modules. Deploying a new service went from **1 week to 2 hours** — write a new `.tfvars` file and call existing modules. |
| **Spotify** | Each music feature (playlists, recommendations, search) is a module composition. The `backend-service` module is called 100+ times with feature-specific config. |
| **Shopify** | Uses multi-region module composition — the same modules deployed to `us-east-1`, `eu-west-1`, `ap-southeast-1` with region-specific `.tfvars`. |
| **Stripe** | Modules include built-in compliance controls (encryption, audit logging). Teams can't accidentally deploy non-compliant infrastructure — it's in the module. |

---

## Business Problems Solved

### Problem 1: "Dev, Staging, and Prod Diverged"

**Symptom:** Staging has 2 EC2 instances. Production has 20. But someone forgot to update staging's security group. Staging is vulnerable. When you deploy to prod, the fix is already in the module — but staging's copy-pasted code is outdated.

**Fix with modules:** Same module, different `.tfvars`:
- `stage/terraform.tfvars`: `min_size = 2`, `max_size = 5`
- `prod/terraform.tfvars`: `min_size = 5`, `max_size = 20`

Update the module once → both environments get the fix.

### Problem 2: "The Database is Wide Open"

**Symptom:** A developer deployed a MySQL database without realizing it was publicly accessible on the internet. Customer data exposed.

**Fix with module composition:** The MySQL module only allows traffic from the webserver's security group:
```hcl
ingress {
  from_port       = 3306
  security_groups = var.webserver_sg_ids  # Only webserver can connect
}
```

The security is **baked into the module** — can't be forgotten.

### Problem 3: "Which Environment Did I Just Change?"

**Symptom:** An engineer runs `terraform apply` in the wrong directory and accidentally changes production instead of staging.

**Fix with separate state files:** Each environment has its own state file in S3:
```
s3://bucket/stage/webserver/terraform.tfstate   ← Can't affect
s3://bucket/prod/webserver/terraform.tfstate    ← these
```

You must explicitly choose which state to operate on.

---

## What We Built vs The Book

| Book's `04-terraform-module/module-example/` | Our `chapter-4/` | Status |
|---|---|---|
| `modules/services/webserver-cluster/` | `modules/services/webserver-cluster/` | ✅ 8 resources |
| `modules/data-stores/mysql/` | `modules/data-stores/mysql/` | ✅ RDS + SG |
| `stage/services/webserver-cluster/` | `stage/services/webserver-cluster/` | ✅ min=2, t3.micro |
| `stage/data-stores/mysql/` | `stage/data-stores/mysql/` | ✅ stagedb, 20GB |
| `prod/services/webserver-cluster/` | `prod/services/webserver-cluster/` | ✅ min=2, t3.micro |
| `prod/data-stores/mysql/` | `prod/data-stores/mysql/` | ✅ proddb, 40GB |

---

## The One Sentence to Remember

> **Module composition lets you build full-stack infrastructure from reusable LEGO blocks — write each piece once, compose them differently for each environment, and security fixes automatically propagate everywhere.**

---

## What's Next

| Chapter | Topic | Status |
|---|---|---|
| **Ch 5** | Loops, Conditionals, Zero-Downtime Deployment | 🔜 Not yet started |
| **Ch 6** | Managing Secrets | 🔜 Not yet started |
| **Ch 7** | Multiple Providers (Kubernetes, multi-region) | 🔜 Not yet started |
