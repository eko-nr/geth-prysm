#!/bin/bash
# Script untuk monitor storage usage

echo "=== Ethereum Node Storage Usage ==="
echo "Execution Layer (Geth):"
du -sh /root/ethereum/execution/
echo ""

echo "Consensus Layer (Prysm):"
du -sh /root/ethereum/consensus/
echo ""

echo "Total Ethereum Data:"
du -sh /root/ethereum/
echo ""

echo "Disk Space Available:"
df -h /root/ethereum/
echo ""

echo "Storage Growth (last 7 days):"
find /root/ethereum/ -type f -mtime -7 -exec du -ch {} + | tail -1

# Setiap bulan, restart dengan database cleanup
docker-compose down
docker exec geth geth removedb --datadir /data
docker-compose up -d