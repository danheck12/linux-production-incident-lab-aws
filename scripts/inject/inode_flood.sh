#!/usr/bin/env bash
set -euo pipefail
TARGET_DIR="${1:-/var/tmp/inodeflood}"
COUNT="${2:-50000}"
sudo mkdir -p "$TARGET_DIR"
for i in $(seq 1 "$COUNT"); do
  sudo sh -c "printf '%s\n' $i > '$TARGET_DIR/file_$i'"
done
sync
df -i /
