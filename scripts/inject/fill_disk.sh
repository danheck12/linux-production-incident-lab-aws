#!/usr/bin/env bash
set -euo pipefail
TARGET_DIR="${1:-/var/tmp/diskfill}"
SIZE_MB="${2:-800}"
sudo mkdir -p "$TARGET_DIR"
sudo dd if=/dev/zero of="$TARGET_DIR/bigfile.bin" bs=1M count="$SIZE_MB" status=progress
sync
df -h /
