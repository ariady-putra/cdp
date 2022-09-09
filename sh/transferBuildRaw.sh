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
AMOUNT=-$3
IN_COUNT=0
while read UTXO
do
    TX_HASH=$(echo $UTXO | cut -d ' ' -f1)
    TX_IX=$(echo $UTXO | cut -d ' ' -f2)
    TX_AMOUNT=$(echo $UTXO | cut -d ' ' -f3)
    TX_IN="$TX_IN --tx-in $TX_HASH#$TX_IX"
    AMOUNT=$(expr $AMOUNT + $TX_AMOUNT)
    IN_COUNT=$(expr $IN_COUNT + 1)
done < utxo/$1.utxo

# Create transaction draft
rm -f transfers/$1/$1.raw
$CARDANO_CLI    transaction build-raw   $TX_IN  \
	--tx-out    $WALLET_ADDR_DST+$3 \
	--tx-out    $WALLET_ADDR_SRC+0  \
    --invalid-hereafter 0   \
	--fee   0   \
	--out-file  transfers/$1/$1.raw

# Query protocol-parameters
rm -f protocol/$1.params
$CARDANO_CLI    query   protocol-parameters \
	--out-file  protocol/$1.params  \
	$CARDANO_MAGIC

# Calculate fee
FEE=$($CARDANO_CLI  transaction calculate-min-fee   \
	--tx-body-file  transfers/$1/$1.raw \
	--tx-in-count   $IN_COUNT   \
	--tx-out-count  2   \
	--witness-count 1   \
	--byron-witness-count   0   \
	--protocol-params-file  protocol/$1.params  \
	$CARDANO_MAGIC  |   cut -d  ' ' -f1)

# Get current slot to calculate validity period
SLOT=$($CARDANO_CLI query   tip \
    $CARDANO_MAGIC  \
    |   sed -n  '6p'    \
    |   cut -d  ':' -f2 \
    |   tr  ',' ' ' \
    |   xargs)
INVALID_HEREAFTER=$(expr $SLOT + 60 \* $4)
echo "Current  slot  is  $SLOT"
echo "Invalid hereafter: $INVALID_HEREAFTER"

# Rebuild transaction draft
rm -f transfers/$1/$1.raw
$CARDANO_CLI    transaction build-raw   $TX_IN  \
	--tx-out    $WALLET_ADDR_DST+$3 \
	--tx-out    $WALLET_ADDR_SRC+$(expr $AMOUNT - $FEE) \
    --invalid-hereafter $INVALID_HEREAFTER  \
	--fee   $FEE    \
	--out-file  transfers/$1/$1.raw

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
