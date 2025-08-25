#!/bin/bash
# Auto-prune storage > 40GB

THRESHOLD=40960  # 40GB in MB
USAGE=$(du -sm /root/ethereum/ | cut -f1)

if [ $USAGE -gt $THRESHOLD ]; then
    echo "Storage usage $USAGE MB exceeded threshold, pruning..."
    docker-compose down
    # Cleanup old logs
    find /root/ethereum/ -name "*.log*" -mtime +7 -delete
    docker-compose up -d
fi