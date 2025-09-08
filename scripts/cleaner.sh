df -h /root/ethereum/execution

docker compose stop prysm
docker compose stop geth
sleep 180   

docker compose run --rm geth snapshot prune-state --datadir /data

docker compose up -d geth prysm

docker logs -n 200 -f geth
