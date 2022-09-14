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
WALLET_ADDR_DST=$4
if test -f wallets/$4/$4.addr; then
    WALLET_ADDR_DST=$(cat wallets/$4/$4.addr)
fi
echo "$WALLET_ADDR_SRC:\n"

# Create tokens directory
mkdir -p tokens/$1

# Generate Base16 token name
TOKEN_NAME=$(echo $2 | xxd -p)

# Query UTXOs
$CARDANO_CLI    query   utxo    \
    --address   $WALLET_ADDR_SRC    \
    $CARDANO_MAGIC  \
    |   tail    +3  \
    >   utxo/$1.utxo
TX_IN=""
TOKEN_AMOUNT=-$3
POLICY_ID=""
while read UTXO
do
    TX_HASH=$(echo  $UTXO | cut -d ' ' -f1)
    TX_IX=$(echo    $UTXO | cut -d ' ' -f2)
    
    IS_TOKEN=$(echo $UTXO | cut -d ' ' -f7)
    if ! [ $IS_TOKEN ]; then
        TX_IN="$TX_IN --tx-in $TX_HASH#$TX_IX"
    fi
    if [ $TOKEN_AMOUNT -lt $3 ] && [ "$TOKEN_NAME" = "$(echo $IS_TOKEN | cut -d '.' -f2)" ]; then
        POLICY_ID=$(echo $IS_TOKEN | cut -d '.' -f1)
        AMOUNT=$(echo $UTXO | cut -d ' ' -f6)
        TOKEN_AMOUNT=$(expr $TOKEN_AMOUNT + $AMOUNT)
        TX_IN="$TX_IN --tx-in $TX_HASH#$TX_IX"
    fi
done < utxo/$1.utxo

# Build transaction raw file
if [ $TOKEN_AMOUNT -gt 0 ]; then
    rm -f tokens/$1/$1.raw
    MIN_REQ_UTXO=$($CARDANO_CLI transaction build   $TX_IN  \
        --tx-out    $WALLET_ADDR_SRC+0+"$TOKEN_AMOUNT $POLICY_ID.$TOKEN_NAME"   \
        --tx-out    $WALLET_ADDR_DST+0+"$3 $POLICY_ID.$TOKEN_NAME"  \
        --change-address    $WALLET_ADDR_SRC    \
        --out-file  tokens/$1/$1.raw    \
        $CARDANO_MAGIC  $CARDANO_ERA    2>&1)
    rm -f tokens/$1/$1.raw
    $CARDANO_CLI    transaction build   $TX_IN  \
        --tx-out    $WALLET_ADDR_SRC+${MIN_REQ_UTXO##* }+"$TOKEN_AMOUNT $POLICY_ID.$TOKEN_NAME" \
        --tx-out    $WALLET_ADDR_DST+${MIN_REQ_UTXO##* }+"$3 $POLICY_ID.$TOKEN_NAME"    \
        --change-address    $WALLET_ADDR_SRC    \
        --out-file  tokens/$1/$1.raw    \
        $CARDANO_MAGIC  $CARDANO_ERA
else
    rm -f tokens/$1/$1.raw
    MIN_REQ_UTXO=$($CARDANO_CLI transaction build   $TX_IN  \
        --tx-out    $WALLET_ADDR_DST+0+"$3 $POLICY_ID.$TOKEN_NAME"  \
        --change-address    $WALLET_ADDR_SRC    \
        --out-file  tokens/$1/$1.raw    \
        $CARDANO_MAGIC  $CARDANO_ERA    2>&1)
    rm -f tokens/$1/$1.raw
    $CARDANO_CLI    transaction build   $TX_IN  \
        --tx-out    $WALLET_ADDR_DST+${MIN_REQ_UTXO##* }+"$3 $POLICY_ID.$TOKEN_NAME"    \
        --change-address    $WALLET_ADDR_SRC    \
        --out-file  tokens/$1/$1.raw    \
        $CARDANO_MAGIC  $CARDANO_ERA
fi

# View the transaction
$CARDANO_CLI    transaction view    \
    --tx-body-file  tokens/$1/$1.raw

# Sign the transaction
rm -f tokens/$1/$1.signed
$CARDANO_CLI    transaction sign    \
    --tx-body-file  tokens/$1/$1.raw    \
    --signing-key-file  wallets/$1/$1.skey  \
    --out-file  tokens/$1/$1.signed \
    $CARDANO_MAGIC

# Submit the transaction to the network
$CARDANO_CLI    transaction submit  \
    --tx-file   tokens/$1/$1.signed \
    $CARDANO_MAGIC

# Show the result tx hash
echo "\nTxHash:"
$CARDANO_CLI    transaction txid    \
    --tx-file   tokens/$1/$1.signed
