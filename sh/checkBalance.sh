# Set wallet by name or address
WALLET=$1
if test -f wallets/$1/$1.addr; then
    WALLET=$(cat wallets/$1/$1.addr)
fi

# Query UTXOs
cardano-cli-1-35-3  query   utxo    \
    --address $WALLET   \
    --testnet-magic 1
