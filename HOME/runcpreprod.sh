#!/bin/bash

cp -fs ~/.local/bin/cardano-node-1-35-3 ~/.local/bin/cardano-node
cp -fs ~/.local/bin/cardano-cli-1-35-3 ~/.local/bin/cardano-cli

echo "preprod" > ~/cardano/cfg/net.cardano
echo "cardano-node-1-35-3" > ~/cardano/cfg/node.cardano
echo "cardano-cli-1-35-3" > ~/cardano/cfg/cli.cardano
echo "--testnet-magic 1" > ~/cardano/cfg/magic.cardano
rm -f ~/cardano/cfg/era.cardano

cardano-node-1-35-3 run \
    --topology ~/cardano/src/cardano-node/configuration/cardano/preprod-topology.json \
    --database-path ~/cardano/db/cardano-preprod \
    --socket-path ~/cardano/node.socket \
    --host-addr 0.0.0.0 \
    --port 13531 \
    --config ~/cardano/src/cardano-node/configuration/cardano/preprod-config.json

