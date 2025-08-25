mkdir -p /root/ethereum/execution
mkdir -p /root/ethereum/consensus

openssl rand -hex 32 > /root/ethereum/jwt.hex
cd ethereum