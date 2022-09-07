# Get env cfg
CARDANO_CLI="cardano-cli"
if test -f ~/cardano/cfg/cli.cardano; then
    CARDANO_CLI=$(cat ~/cardano/cfg/cli.cardano)
fi
CARDANO_MAGIC="--mainnet"
if test -f ~/cardano/cfg/magic.cardano; then
    CARDANO_MAGIC=$(cat ~/cardano/cfg/magic.cardano)
fi
CARDANO_ERA=""
if test -f ~/cardano/cfg/era.cardano; then
    CARDANO_ERA=$(cat ~/cardano/cfg/era.cardano)
fi

# Get wallet addresses from wallet names
WALLET_ADDR_SRC=$(cat wallets/$1/$1.addr)
WALLET_ADDR_DST=$2
if test -f wallets/$2/$2.addr; then
    WALLET_ADDR_DST=$(cat wallets/$2/$2.addr)
fi

# Query UTXOs
echo "$WALLET_ADDR_SRC:\n"
$CARDANO_CLI    query   utxo    \
    --address   $WALLET_ADDR_SRC    \
    $CARDANO_MAGIC  \
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
$CARDANO_CLI    transaction build   $TX_IN  \
    --tx-out    $WALLET_ADDR_DST+$3 \
    --change-address    $WALLET_ADDR_SRC    \
    --out-file  transfers/$1/$1.raw \
    $CARDANO_MAGIC  $CARDANO_ERA

# View the transaction
$CARDANO_CLI    transaction view    \
    --tx-body-file  transfers/$1/$1.raw

# Sign the transaction
rm -f transfers/$1/$1.signed
$CARDANO_CLI    transaction sign    \
    --tx-body-file  transfers/$1/$1.raw \
    --signing-key-file  wallets/$1/$1.skey  \
    --out-file  transfers/$1/$1.signed  \
    $CARDANO_MAGIC

# Submit the transaction to the network
$CARDANO_CLI    transaction submit  \
    --tx-file   transfers/$1/$1.signed  \
    $CARDANO_MAGIC

# Show the result tx hash
echo "\nTxHash:"
$CARDANO_CLI    transaction txid    \
    --tx-file   transfers/$1/$1.signed
