# Get wallet addresses from wallet names
WALLET_ADDR_SRC=$(cat wallets/$1/$1.addr)
WALLET_ADDR_DST=$2
if test -f wallets/$2/$2.addr; then
    WALLET_ADDR_DST=$(cat wallets/$2/$2.addr)
fi

# Query UTXOs
cardano-cli-1-35-3  query utxo  \
    --address   $WALLET_ADDR_SRC    \
    --testnet-magic 1   \
    |   tail    +3  \
    >   utxo/$1.utxo
TX_IN=""
while read UTXO
do
    TX_HASH=$(echo $UTXO | cut -d ' ' -f1)
    TX_IX=$(echo $UTXO | cut -d ' ' -f2)
    TX_IN="$TX_IN --tx-in $TX_HASH#$TX_IX"
done < utxo/$1.utxo

# Build transaction raw file
mkdir -p transfers/$1
rm -f transfers/$1/$1.raw
cardano-cli-1-35-3  transaction build   $TX_IN  \
    --tx-in-script-file wallets/$1/$1.multisig  \
    --witness-override  3   \
    --tx-out    $WALLET_ADDR_DST+$3 \
    --change-address    $WALLET_ADDR_SRC    \
    --out-file  transfers/$1/$1.raw \
    --testnet-magic 1

# View the transaction
cardano-cli-1-35-3  transaction view    \
    --tx-body-file  transfers/$1/$1.raw

# Witness the transaction by each user
rm -f transfers/$1/$1.$4
cardano-cli-1-35-3  transaction witness \
    --signing-key-file  wallets/$4/$4.skey  \
    --tx-body-file  transfers/$1/$1.raw \
    --out-file  transfers/$1/$1.$4

rm -f transfers/$1/$1.$5
cardano-cli-1-35-3  transaction witness \
    --signing-key-file  wallets/$5/$5.skey  \
    --tx-body-file  transfers/$1/$1.raw \
    --out-file  transfers/$1/$1.$5

rm -f transfers/$1/$1.$6
cardano-cli-1-35-3  transaction witness \
    --signing-key-file  wallets/$6/$6.skey  \
    --tx-body-file  transfers/$1/$1.raw \
    --out-file  transfers/$1/$1.$6

# Assemble the transaction
rm -f transfers/$1/$1.signed
cardano-cli-1-35-3  transaction assemble    \
    --tx-body-file  transfers/$1/$1.raw \
    --witness-file  transfers/$1/$1.$4  \
    --witness-file  transfers/$1/$1.$5  \
    --witness-file  transfers/$1/$1.$6  \
    --out-file  transfers/$1/$1.signed

# Submit the transaction to the network
cardano-cli-1-35-3  transaction submit  \
    --tx-file   transfers/$1/$1.signed  \
    --testnet-magic 1
