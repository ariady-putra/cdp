# Get wallet address from wallet name
WALLET_ADDR=$(cat wallets/$1/$1.addr)

# Query UTXOs
cardano-cli-1-35-3  query   utxo    \
    --address $WALLET_ADDR  \
    --testnet-magic 1
