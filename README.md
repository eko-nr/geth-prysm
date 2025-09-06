# Ethereum Sepolia Testnet Node

A Docker-based Ethereum Sepolia testnet node setup with Geth (execution client) and Prysm (consensus client), including automated storage management and security configurations.

## 🏗️ Architecture

This setup runs a full Ethereum Sepolia testnet node consisting of:

- **Geth** (`ethereum/client-go:stable`) - Execution layer client
- **Prysm** (`gcr.io/prysmaticlabs/prysm/beacon-chain`) - Consensus layer beacon chain client
- **NFTables** - Firewall configuration for security
- **Automated storage management** - Prevents disk space issues

## 📋 Prerequisites

- Linux server with Docker and Docker Compose
- At least 50GB free disk space (recommended: 100GB+)
- Reliable internet connection
- Root access for directory creation and firewall management

## 🚀 Quick Start

### 1. Generate JWT Secret

The JWT secret enables secure communication between execution and consensus clients:

```bash
chmod +x scripts/generate_jwt.sh
./scripts/generate_jwt.sh
```

This creates:
- `/root/ethereum/execution/` - Geth data directory
- `/root/ethereum/consensus/` - Prysm data directory  
- `/root/ethereum/jwt.hex` - Shared JWT secret

### 2. Deploy the Node

```bash
docker-compose up -d
```

### 3. Monitor Logs

```bash
# View all services
docker-compose logs -f

# View specific service
docker-compose logs -f geth
docker-compose logs -f prysm
```

## 🔧 Configuration Details

### Geth (Execution Client)

**Network Configuration:**
- Sepolia testnet
- Snap sync mode for faster initial sync
- HTTP RPC enabled on port 8545
- WebSocket on port 8546
- Auth RPC on port 8551 (consensus communication)

**Performance Settings:**
- Cache: 50,960 MB
- Max peers: 40
- P2P port: 30303 (TCP/UDP)

**Data Storage:**
- Data directory: `/root/ethereum/execution`
- Log rotation: 10MB max, 3 files retained

### Prysm (Consensus Client)

**Network Configuration:**
- Sepolia testnet
- Checkpoint sync enabled for faster initial sync
- RPC on port 4000
- gRPC gateway on port 3500
- P2P: TCP 13000, UDP 12000

**Performance Settings:**
- Max peers: 55
- Min sync peers: 3
- Max goroutines: 3000
- GC percent: 75

**Checkpoint Sync:**
- URL: `https://checkpoint-sync.sepolia.ethpandaops.io`
- Enables rapid sync to current chain head

## 🛡️ Security (NFTables)

### Firewall Rules

The `nftables.conf` provides comprehensive security:

**Allowed Traffic:**
- SSH (port 22)
- Ethereum P2P (30303 TCP/UDP)
- Prysm P2P (13000 TCP, 12000 UDP) with connection limits
- RPC access from localhost and whitelisted IPs
- ICMP for diagnostics (rate limited)

**Security Features:**
- Default deny policy
- Connection rate limiting
- IP whitelisting for RPC access
- Localhost-only access for sensitive ports

### Apply Firewall

```bash
# Apply rules
sudo nft -f nftables.conf

# Make persistent (systemd)
sudo cp nftables/nftables.conf /etc/nftables.conf
sudo systemctl enable nftables
```

**⚠️ Important:** Add your management IPs to the `rpc_allow_ips` set before applying!

## 📊 Storage Monitoring & Management

### Storage Monitoring Script

The `storage-monitoring.sh` script provides comprehensive storage insights and maintenance:

```bash
# Make executable
chmod +x scripts/storage-monitoring.sh

# Run storage report
./scripts/storage-monitoring.sh
```

**Monitoring Features:**
- **Execution Layer Usage:** Shows Geth data directory size
- **Consensus Layer Usage:** Shows Prysm data directory size  
- **Total Storage:** Combined Ethereum data usage
- **Available Space:** Disk space remaining
- **Growth Tracking:** New data added in last 7 days

### Monthly Database Cleanup

The script includes automated monthly maintenance:

```bash
# Add to crontab for monthly execution
crontab -e
# Add: 0 3 1 * * /path/to/scripts/storage-monitoring.sh
```

**Cleanup Process:**
1. Gracefully stops all services
2. Removes Geth database (forces full resync)
3. Restarts services with fresh database
4. Maintains consensus layer data for faster sync

**⚠️ Note:** Monthly cleanup triggers full Geth resync (~6-12 hours) but prevents storage bloat.

## 📊 Monitoring & Maintenance

### Health Checks

```bash
# Check sync status
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  http://localhost:8545

# Check peer count
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' \
  http://localhost:8545

# Prysm beacon node status
curl http://localhost:3500/eth/v1/node/health
```

### Log Management

Logs are automatically rotated (10MB max, 3 files) but you can also:

```bash
# Clear all logs
docker-compose logs --no-log-prefix > /dev/null 2>&1

# View specific service logs with timestamps
docker-compose logs -f -t geth
```

### Updates

```bash
# Update to latest images
docker-compose pull
docker-compose up -d
```

## 🔌 RPC Access

### Local Access
- HTTP RPC: `http://localhost:8545`
- WebSocket: `ws://localhost:8546`
- Prysm REST API: `http://localhost:3500`
- Prysm RPC: `localhost:4000`

### External Access
Add your IP to `rpc_allow_ips` in `nftables.conf` for external RPC access.

## 📈 Performance Tuning

### For Higher Performance
```yaml
# In docker-compose.yml, adjust:
geth:
  command:
    - --cache=102400  # Increase if you have more RAM
    - --maxpeers=100  # More peers for better connectivity

prysm:
  command:
    - --p2p-max-peers=100
    - --max-goroutines=5000  # Increase for powerful hardware
```

### For Lower Resource Usage
```yaml
geth:
  command:
    - --cache=25600   # Reduce cache
    - --maxpeers=20   # Fewer peers

prysm:
  command:
    - --p2p-max-peers=30
    - --max-goroutines=1500
```

## 🚨 Troubleshooting

### Common Issues

**Geth won't start:**
```bash
# Check JWT secret permissions
ls -la /root/ethereum/jwt.hex
# Should be readable by container user
```

**Prysm sync issues:**
```bash
# Reset consensus data (loses sync progress)
docker-compose down
sudo rm -rf /root/ethereum/consensus/*
docker-compose up -d
```

**Port conflicts:**
```bash
# Check what's using ports
sudo netstat -tulpn | grep -E ":(8545|8546|8551|4000|3500|30303)"
```

**High disk usage:**
```bash
# Check storage breakdown
./scripts/storage-monitoring.sh

# Manual monthly cleanup (triggers full resync)
docker-compose down
docker exec geth geth removedb --datadir /data
docker-compose up -d
```

### Getting Help

- **Geth Documentation:** https://geth.ethereum.org/docs
- **Prysm Documentation:** https://docs.prylabs.network
- **Ethereum Discord:** https://discord.gg/ethereum-org

## 📄 File Structure

```
.
├── docker-compose.yml           # Main service definitions
├── nftables.conf               # Firewall configuration
├── scripts/                    # Management scripts
│   ├── generate_jwt.sh         # JWT secret generation
│   └── storage-monitoring.sh   # Storage monitoring & cleanup
└── /root/ethereum/             # Data directory
    ├── execution/              # Geth data
    ├── consensus/              # Prysm data
    └── jwt.hex                 # Shared authentication
```

## ⚖️ License

This configuration is provided as-is for educational and development purposes. Please ensure compliance with your local regulations when running blockchain infrastructure.

---

**Note:** This is a Sepolia testnet configuration. For mainnet deployment, additional considerations for security, backup strategies, and monitoring are required.