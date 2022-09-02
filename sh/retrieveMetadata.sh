# Retrieve METADATA from Blockfrost
# curl -H "project_id:$BF_PID" https://cardano-mainnet.blockfrost.io/api/v0/metadata/txs/labels/$1 | jq
# curl -H "project_id:$BF_PID" https://cardano-testnet.blockfrost.io/api/v0/metadata/txs/labels/$1 | jq
# curl -H "project_id:$BF_PID" https://cardano-preprod.blockfrost.io/api/v0/metadata/txs/labels/$1 | jq
curl -H "project_id:$BF_PID" https://cardano-preview.blockfrost.io/api/v0/metadata/txs/labels/$1 | jq
