#!/usr/bin/env bash
set -euo pipefail
sudo rm -rf /var/tmp/diskfill
sync
df -h /
