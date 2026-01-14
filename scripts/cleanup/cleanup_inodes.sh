#!/usr/bin/env bash
set -euo pipefail
sudo rm -rf /var/tmp/inodeflood
sync
df -i /
