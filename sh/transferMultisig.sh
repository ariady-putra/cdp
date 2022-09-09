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

# Get current slot to calculate validity period
SLOT=$($CARDANO_CLI query   tip \
    $CARDANO_MAGIC  \
    |   sed -n  '6p'    \
    |   cut -d  ':' -f2 \
    |   tr  ',' ' ' \
    |   xargs)
INVALID_HEREAFTER=$(expr $SLOT + 60 \* $7)
echo "Current  slot  is  $SLOT"
echo "Invalid hereafter: $INVALID_HEREAFTER"

# Build transaction raw file
mkdir -p transfers/$1
rm -f transfers/$1/$1.raw
$CARDANO_CLI    transaction build   $TX_IN  \
    --tx-in-script-file wallets/$1/$1.multisig  \
    --invalid-before    $SLOT   \
    --invalid-hereafter $INVALID_HEREAFTER  \
    --witness-override  3   \
    --tx-out    $WALLET_ADDR_DST+$3 \
    --change-address    $WALLET_ADDR_SRC    \
    --out-file  transfers/$1/$1.raw \
    $CARDANO_MAGIC  $CARDANO_ERA

# View the transaction
$CARDANO_CLI    transaction view    \
    --tx-body-file  transfers/$1/$1.raw

# Witness the transaction by each user
rm -f transfers/$1/$1.$4
$CARDANO_CLI    transaction witness \
    --signing-key-file  wallets/$4/$4.skey  \
    --tx-body-file  transfers/$1/$1.raw \
    --out-file  transfers/$1/$1.$4

rm -f transfers/$1/$1.$5
$CARDANO_CLI    transaction witness \
    --signing-key-file  wallets/$5/$5.skey  \
    --tx-body-file  transfers/$1/$1.raw \
    --out-file  transfers/$1/$1.$5

rm -f transfers/$1/$1.$6
$CARDANO_CLI    transaction witness \
    --signing-key-file  wallets/$6/$6.skey  \
    --tx-body-file  transfers/$1/$1.raw \
    --out-file  transfers/$1/$1.$6

# Assemble the transaction
rm -f transfers/$1/$1.signed
$CARDANO_CLI    transaction assemble    \
    --tx-body-file  transfers/$1/$1.raw \
    --witness-file  transfers/$1/$1.$4  \
    --witness-file  transfers/$1/$1.$5  \
    --witness-file  transfers/$1/$1.$6  \
    --out-file  transfers/$1/$1.signed

# Submit the transaction to the network
$CARDANO_CLI    transaction submit  \
    --tx-file   transfers/$1/$1.signed  \
    $CARDANO_MAGIC

# Show the result tx hash
echo "\nTxHash:"
$CARDANO_CLI    transaction txid    \
    --tx-file   transfers/$1/$1.signed
