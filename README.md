![Last Commit](https://img.shields.io/github/last-commit/danheck12/linux-production-incident-lab-aws)
![Repo Size](https://img.shields.io/github/repo-size/danheck12/linux-production-incident-lab-aws)
![Stars](https://img.shields.io/github/stars/danheck12/linux-production-incident-lab-aws?style=social)
![Terraform](https://img.shields.io/badge/terraform-infrastructure-blue)
![ShellCheck](https://github.com/danheck12/linux-production-incident-lab-aws/actions/workflows/shellcheck.yml/badge.svg)


Hands-on Linux reliability lab built on AWS EC2. Reproduces real production failure modes (disk full, inode exhaustion, OOM, systemd crashloops, DNS failures) and documents **diagnosis, mitigation, recovery, and prevention** using runbooks and postmortems.

Access paths:
- **SSH** (restricted to single IP)
- **AWS SSM Session Manager** (break-glass recovery)

> ⚠️ This project intentionally breaks things. Run only in disposable lab environments.

---

## Table of Contents
- [Architecture](#architecture)
- [What This Demonstrates](#what-this-demonstrates)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Run Drills](#run-drills)
- [Cleanup](#cleanup)
- [Planned Incidents](#planned-incidents)
- [Teardown](#teardown)

---

## Architecture
- 1× EC2 Ubuntu 24.04 instance
- IAM instance profile with `AmazonSSMManagedInstanceCore`
- Security Group:
  - SSH (22) allowed only from a single CIDR
- Extra EBS volume attached for filesystem and fstab drills
- Primary user: **ares**

---

## What This Demonstrates
- Linux incident response patterns: triage → diagnosis → mitigation → recovery → prevention
- Debugging with `lsof`, `strace`, `/proc`, `journalctl`, `systemctl`, `df`, `du`
- Break-glass recovery using SSM Session Manager
- Reproducible infrastructure with Terraform
- Real-world operational thinking (runbooks + postmortems)

---

## Repository Structure
.
├── terraform/ # EC2 + IAM + SG + EBS provisioning
├── scripts/
│ ├── inject/ # failure injection scripts
│ └── cleanup/ # cleanup scripts
├── docs/
│ ├── runbooks/ # step-by-step recovery procedures
│ └── incidents/ # incident writeups/postmortems
└── evidence/ # optional captured outputs/screenshots

yaml
Copy code

---

## Getting Started

### Prerequisites
- AWS CLI configured (`aws sts get-caller-identity` works)
- Terraform 1.5+
- An SSH keypair (`~/.ssh/id_ed25519.pub` or similar)

---

### Provision the lab

```bash
cd terraform
terraform init
terraform apply \
  -var="ssh_cidr=107.140.205.52/32" \
  -var="ssh_public_key_path=$HOME/.ssh/id_ed25519.pub"
After apply:

bash
Copy code
terraform output
SSH into the instance
bash
Copy code
ssh -i ~/.ssh/id_ed25519 ares@$(terraform output -raw public_ip)
SSM Session (break-glass)
AWS Console → Systems Manager → Session Manager → Start session → select instance

Run Drills
Disk Full
bash
Copy code
./scripts/inject/fill_disk.sh
# follow docs/runbooks/disk-full.md
./scripts/cleanup/cleanup_disk.sh
Inode Exhaustion
bash
Copy code
./scripts/inject/inode_flood.sh /var/tmp/inodeflood 50000
# follow docs/runbooks/inode-exhaustion.md
./scripts/cleanup/cleanup_inodes.sh
Cleanup
Always run cleanup scripts after drills:

scripts/cleanup/cleanup_disk.sh

scripts/cleanup/cleanup_inodes.sh

Planned Incidents
FD leak (lsof, /proc/<pid>/fd, ulimit)

systemd crashloop (journalctl -u, systemctl, systemd-analyze)

Broken DNS (resolvectl, dig, strace)

OOM killer (journalctl -k, dmesg, memory pressure)

Zombie processes

Runaway CPU

Teardown
bash
Copy code
cd terraform
terraform destroy
