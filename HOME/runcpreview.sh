#!/bin/bash

cp -fs ~/.local/bin/cardano-node-1-35-3 ~/.local/bin/cardano-node
cp -fs ~/.local/bin/cardano-cli-1-35-3 ~/.local/bin/cardano-cli

echo "preview" > ~/cardano/cfg/net.cardano
echo "cardano-node-1-35-3" > ~/cardano/cfg/node.cardano
echo "cardano-cli-1-35-3" > ~/cardano/cfg/cli.cardano
echo "--testnet-magic 2" > ~/cardano/cfg/magic.cardano
rm -f ~/cardano/cfg/era.cardano

cardano-node-1-35-3 run \
    --topology ~/cardano/src/cardano-node/configuration/cardano/preview-topology.json \
    --database-path ~/cardano/db/cardano-preview \
    --socket-path ~/cardano/node.socket \
    --host-addr 0.0.0.0 \
    --port 13532 \
    --config ~/cardano/src/cardano-node/configuration/cardano/preview-config.json

