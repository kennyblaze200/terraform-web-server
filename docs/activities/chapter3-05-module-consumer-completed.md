# Deployment Activity: `05-module-consumer`

## Status: ✅ Deployed — ⚠️ Not Yet Destroyed

## Goal

Learn how to **consume a reusable Terraform module** — the single most important pattern in production infrastructure.

## What This Project Teaches

This project calls the `webserver-cluster` module (extracted from Chapter 2) with environment-specific configuration. It demonstrates the **module composition pattern** used by every major tech company.

### 4 Key Module Concepts

| Concept                          | Code                                                                                             | What Happened                                          |
| -------------------------------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------ |
| **Module Source**                | [`source = "../modules/webserver-cluster"`](../../chapter-3/05-module-consumer/main.tf:51)       | Terraform loaded the module from a local path          |
| **Data Sources → Module Inputs** | [`vpc_id = data.aws_vpc.default.id`](../../chapter-3/05-module-consumer/main.tf:56)              | Root discovered VPC, subnets, AMI — passed into module |
| **Module Variables**             | [`cluster_name, ami, vpc_id, subnet_ids, ...`](../../chapter-3/05-module-consumer/main.tf:53-63) | 9 variables configured the module's behavior           |
| **Module Outputs**               | [`module.webserver_cluster.alb_dns_name`](../../chapter-3/05-module-consumer/outputs.tf:8)       | 4 outputs read back from the module                    |

## Resources Created

All prefixed with `module.webserver_cluster.`:

| Resource                        | ID                                           | Value                                         |
| ------------------------------- | -------------------------------------------- | --------------------------------------------- |
| `aws_security_group.instance`   | `sg-0c4df94084caeb138`                       | Port 80 ingress, all egress                   |
| `aws_security_group.alb`        | `sg-01bb8b83f4b51acf7`                       | Port 80 ingress                               |
| `aws_launch_template.example`   | `lt-007c99b342c5d2d62`                       | AMI `ami-02fd066b86800f60c`, t3.micro, Apache |
| `aws_autoscaling_group.example` | `terraform-module-demo-asg`                  | min=2, max=5, desired=2                       |
| `aws_lb.example`                | `terraform-module-demo-alb`                  | Internet-facing, port 80                      |
| `aws_lb_listener.http`          | —                                            | Port 80 → 404 default                         |
| `aws_lb_target_group.asg`       | `terraform-module-demo-tg`                   | Health check `/` → 200                        |
| `aws_lb_listener_rule.asg`      | —                                            | Path `/*` → forward to TG                     |
| **2 EC2 instances**             | `i-05d14a9afd1ceb689`, `i-06680c1cf1be76678` | t3.micro at `34.224.166.227`, `3.237.42.102`  |

## Bug Fix Applied

**Error:** `InvalidPermission.Duplicate: the specified rule "peer: 0.0.0.0/0, ALL, ALLOW" already exists`

**Root cause:** The `create_before_destroy` lifecycle on the security group created a conflict with an existing (tainted) SG.

**Fix:** Re-ran `terraform apply` which resolved the state drift.

## Real-World Application

### The Problem This Solves

Imagine your company runs 3 environments: **dev**, **staging**, **prod**. Each needs a web cluster (ASG + ALB).

**Without modules:** You copy-paste the same 100-line configuration 3 times. A security fix in dev is forgotten in prod. **This causes real outages.**

**With modules:** You write the cluster code once in `modules/webserver-cluster/`. Each environment calls it with different variables:

```hcl
# dev — 2 lines
module "cluster" { source = "../modules/webserver-cluster"; min_size = 1 }

# staging — 2 lines
module "cluster" { source = "../modules/webserver-cluster"; min_size = 2 }

# prod — 2 lines
module "cluster" { source = "../modules/webserver-cluster"; min_size = 10 }
```

A security fix in the module propagates to **all three environments instantly**.

### How Real Companies Use This Pattern

| Company     | Module Pattern                                         | Impact                                            |
| ----------- | ------------------------------------------------------ | ------------------------------------------------- |
| **Netflix** | `base-networking` module (VPC + subnets + NAT)         | Every team gets identical, secure networking      |
| **Airbnb**  | 40+ modules for different infrastructure patterns      | Deploy time dropped from **days to minutes**      |
| **Spotify** | `microservice` module (ALB + ECS + RDS)                | New service deployed with one module call         |
| **Stripe**  | `payment-processing` module with built-in PCI controls | Compliance can't be bypassed — it's in the module |
| **Shopify** | Multi-region modules for global expansion              | Same infrastructure deployed to US, EU, APAC      |

### The ALB Test

The ALB DNS name: `http://terraform-module-demo-alb-290524204.us-east-1.elb.amazonaws.com`

Opening this URL shows the load balancer distributing traffic between 2 EC2 instances — **same pattern as Chapter 2, but now powered by a reusable module**.

## Key Takeaway

> **Modules turn infrastructure into a library — write complex code once, call it everywhere with simple variables, and security fixes propagate automatically.**

## ⚠️ Action Required

Resources are still running. Destroy with:

```bash
cd /d C:\Users\T490\Documents\modulo-vault\terraform-aws-modules\chapter-3\05-module-consumer
terraform destroy -auto-approve
```
