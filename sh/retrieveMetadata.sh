# Retrieve METADATA from Blockfrost
curl -H "project_id:$WTA_BF_PID" https://cardano-testnet.blockfrost.io/api/v0/metadata/txs/labels/$1 | jq
