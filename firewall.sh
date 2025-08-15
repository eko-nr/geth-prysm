# Install UFW (if not already installed)
sudo apt update
sudo apt install ufw

# Enable UFW
sudo ufw enable
# Check status
sudo ufw status
# Allow SSH (IMPORTANT: Do this first to avoid getting locked out)
sudo ufw allow ssh
sudo ufw allow 22


# Allow outgoing connections
sudo ufw default allow outgoing
# Deny incoming by default
sudo ufw default deny incoming

# Allow P2P connections for blockchain sync
sudo ufw allow 30303



# Method A: Allow only localhost
sudo ufw allow from 127.0.0.1 to any port 8545

# Method B: Allow specific IP
# sudo ufw allow from 192.168.1.100 to any port 8545

# Method C: Allow entire local network
sudo ufw allow from 192.168.1.0/24 to any port 8545

# Method D: Allow multiple specific IPs
# sudo ufw allow from 192.168.1.100 to any port 8545
# sudo ufw allow from 192.168.1.200 to any port 8545
# sudo ufw allow from 10.0.0.50 to any port 8545



# WebSocket endpoint
sudo ufw allow from 127.0.0.1 to any port 8546
sudo ufw allow from 192.168.1.0/24 to any port 8546

# Auth RPC (for consensus client)
sudo ufw allow from 127.0.0.1 to any port 8551

# Prysm ports (if accessed externally)
sudo ufw allow from 192.168.1.0/24 to any port 4000
sudo ufw allow from 192.168.1.0/24 to any port 3500

sudo ufw reload