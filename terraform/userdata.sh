#!/usr/bin/env bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y \
  curl wget vim git jq \
  htop lsof strace \
  net-tools dnsutils \
  sysstat psmisc \
  python3 python3-pip \
  build-essential \
  stress-ng

# Create user 'ares'
id ares &>/dev/null || useradd -m -s /bin/bash ares
usermod -aG sudo ares

# Allow passwordless sudo for ares (lab only)
echo "ares ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-ares
chmod 440 /etc/sudoers.d/90-ares

# Create workspace
mkdir -p /opt/incident-lab
chown -R ares:ares /opt/incident-lab

# Persist journald logs
mkdir -p /var/log/journal
systemctl restart systemd-journald

echo "Bootstrap complete."
