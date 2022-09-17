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
WALLET_ADDR_SRC1=$(cat wallets/$1/$1.addr)
WALLET_ADDR_SRC2=$(cat wallets/$2/$2.addr)
WALLET_ADDR_DST=$3
if test -f wallets/$3/$3.addr; then
    WALLET_ADDR_DST=$(cat wallets/$3/$3.addr)
fi
WALLET_ADDR_CHG=$4
if test -f wallets/$4/$4.addr; then
    WALLET_ADDR_CHG=$(cat wallets/$4/$4.addr)
fi

# Query UTXOs
echo "$WALLET_ADDR_SRC1:\n$WALLET_ADDR_SRC2:\n"
$CARDANO_CLI    query   utxo    \
    --address   $WALLET_ADDR_SRC1   \
    $CARDANO_MAGIC  \
    |   tail    +3  \
    >   utxo/$1.utxo
$CARDANO_CLI    query   utxo    \
    --address   $WALLET_ADDR_SRC2   \
    $CARDANO_MAGIC  \
    |   tail    +3  \
    >   utxo/$2.utxo
TX_IN=""
AMOUNT=-$5
IN_COUNT=0
while read UTXO
do
    TX_HASH=$(echo      $UTXO | egrep -o '[0-9A-Za-z]+' | sed -n 1p)
    TX_IX=$(echo        $UTXO | egrep -o '[0-9A-Za-z]+' | sed -n 2p)
    TX_AMOUNT=$(echo    $UTXO | egrep -o '[0-9A-Za-z]+' | sed -n 3p)
    
    IS_TOKEN=$(echo     $UTXO | egrep -o '[0-9A-Za-z]+' | sed -n 7p)
    if ! [ $IS_TOKEN ]; then
        TX_IN="$TX_IN --tx-in $TX_HASH#$TX_IX"
        AMOUNT=$(expr   $AMOUNT + $TX_AMOUNT)
        IN_COUNT=$(expr $IN_COUNT + 1)
    fi
done < utxo/$1.utxo
while read UTXO
do
    TX_HASH=$(echo      $UTXO | egrep -o '[0-9A-Za-z]+' | sed -n 1p)
    TX_IX=$(echo        $UTXO | egrep -o '[0-9A-Za-z]+' | sed -n 2p)
    TX_AMOUNT=$(echo    $UTXO | egrep -o '[0-9A-Za-z]+' | sed -n 3p)
    
    IS_TOKEN=$(echo     $UTXO | egrep -o '[0-9A-Za-z]+' | sed -n 7p)
    if ! [ $IS_TOKEN ]; then
        TX_IN="$TX_IN --tx-in $TX_HASH#$TX_IX"
        AMOUNT=$(expr   $AMOUNT + $TX_AMOUNT)
        IN_COUNT=$(expr $IN_COUNT + 1)
    fi
done < utxo/$2.utxo

# Create transaction draft
rm -f transfers/$1/$1.raw
$CARDANO_CLI    transaction build-raw   $TX_IN  \
	--tx-out    $WALLET_ADDR_DST+$5 \
	--tx-out    $WALLET_ADDR_CHG+0  \
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
	--witness-count 2   \
	--byron-witness-count   0   \
	--protocol-params-file  protocol/$1.params  \
	$CARDANO_MAGIC  |   cut -d  ' ' -f1)

# Rebuild transaction draft
rm -f transfers/$1/$1.raw
$CARDANO_CLI    transaction build-raw   $TX_IN  \
	--tx-out    $WALLET_ADDR_DST+$5 \
	--tx-out    $WALLET_ADDR_CHG+$(expr $AMOUNT - $FEE) \
	--fee   $FEE    \
	--out-file  transfers/$1/$1.raw

# View the transaction
$CARDANO_CLI    transaction view    \
    --tx-body-file  transfers/$1/$1.raw

# Witness the transaction by each user
rm -f transfers/$1/$1.witness
$CARDANO_CLI    transaction witness \
    --signing-key-file  wallets/$1/$1.skey  \
    --tx-body-file  transfers/$1/$1.raw \
    --out-file  transfers/$1/$1.witness

rm -f transfers/$2/$2.witness
$CARDANO_CLI    transaction witness \
    --signing-key-file  wallets/$2/$2.skey  \
    --tx-body-file  transfers/$1/$1.raw \
    --out-file  transfers/$2/$2.witness

# Assemble the transaction
rm -f transfers/$1/$1.signed
$CARDANO_CLI    transaction assemble    \
    --tx-body-file  transfers/$1/$1.raw \
    --witness-file  transfers/$1/$1.witness \
    --witness-file  transfers/$2/$2.witness \
    --out-file  transfers/$1/$1.signed

# Submit the transaction to the network
$CARDANO_CLI    transaction submit  \
    --tx-file   transfers/$1/$1.signed  \
    $CARDANO_MAGIC

# Show the result tx hash
echo "\nTxHash:"
$CARDANO_CLI    transaction txid    \
    --tx-file   transfers/$1/$1.signed
