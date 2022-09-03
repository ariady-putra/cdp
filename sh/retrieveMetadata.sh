# Get env cfg
CARDANO_NET="mainnet"
if test -f ~/cardano/cfg/net.cardano; then
    CARDANO_NET=$(cat ~/cardano/cfg/net.cardano)
fi

# Retrieve METADATA from Blockfrost
curl    -H  "project_id:$BF_PID"    \
    https://cardano-$CARDANO_NET.blockfrost.io/api/v0/metadata/txs/labels/$1    \
    |   jq
