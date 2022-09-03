#!/bin/bash

echo "testnet" > ~/cardano/cfg/net.cardano
echo "cardano-node-1-35-2" > ~/cardano/cfg/node.cardano
echo "cardano-cli-1-35-2" > ~/cardano/cfg/cli.cardano
echo "--testnet-magic 1097911063" > ~/cardano/cfg/magic.cardano
echo "--babbage-era" > ~/cardano/cfg/era.cardano

cardano-node-1-35-2 run \
    --topology ~/cardano-src/cardano-node/configuration/cardano/testnet-topology.json \
    --database-path ~/cardano/db/cardano-testnet \
    --socket-path ~/cardano/node.socket \
    --host-addr 0.0.0.0 \
    --port 60514 \
    --config ~/cardano-src/cardano-node/configuration/cardano/testnet-config.json

