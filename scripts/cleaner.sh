#!/bin/bash
# Auto-remove old Geth logs (>2 days)

TARGET_DIR="/root/ethereum"

# Cek direktori
if [ ! -d "$TARGET_DIR" ]; then
  echo "Directory $TARGET_DIR not found!"
  exit 1
fi

echo "Pruning old logs in $TARGET_DIR..."

# Stop container sementara (lebih aman daripada down)
docker-compose stop

# Hapus log lebih dari 2 hari
find "$TARGET_DIR" -name "*.log*" -type f -mtime +2 -print -delete

# Start lagi container
docker-compose start

echo "Log cleanup finished."
