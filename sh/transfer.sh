# Get wallet addresses from wallet names
WALLET_ADDR_SRC=$(cat wallets/$1/$1.addr)
WALLET_ADDR_DST=$(cat wallets/$2/$2.addr)

# Query UTXO
TX_HASH_IX_AMOUNT=$(cardano-cli-1-35-3  query utxo  \
    --address   $WALLET_ADDR_SRC    \
    --testnet-magic 1   |   sed -n  3p)

TX_HASH=$(echo $TX_HASH_IX_AMOUNT | cut -d ' ' -f1)
TX_IX=$(echo $TX_HASH_IX_AMOUNT | cut -d ' ' -f2)
AMOUNT=$(echo $TX_HASH_IX_AMOUNT | cut -d ' ' -f3)

# Build transaction raw file
mkdir -p transfers/$1
rm -f transfers/$1/$1.raw
cardano-cli-1-35-3  transaction build   \
    --tx-in $TX_HASH#$TX_IX \
    --tx-out    $WALLET_ADDR_DST+$3 \
    --change-address    $WALLET_ADDR_SRC    \
    --out-file  transfers/$1/$1.raw \
    --testnet-magic 1

# Sign the transaction
rm -f transfers/$1/$1.signed
cardano-cli-1-35-3  transaction sign    \
    --signing-key-file wallets/$1/$1.skey   \
    --tx-body-file  transfers/$1/$1.raw \
    --out-file  transfers/$1/$1.signed  \
    --testnet-magic 1

# Submit the transaction to the network
cardano-cli-1-35-3  transaction submit  \
    --tx-file   transfers/$1/$1.signed  \
    --testnet-magic 1
