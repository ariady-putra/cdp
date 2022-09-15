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
WALLET_ADDR=$(cat wallets/$1/$1.addr)
echo "$WALLET_ADDR:\n"

# Populate policy name
POLICY_NAME=$4

# Create NFT directory
mkdir -p nft/$1

# Generate key hashes
KEYHASH=$($CARDANO_CLI  address key-hash    \
    --payment-verification-key-file nft/$1/$POLICY_NAME.vkey)

# Generate Base16 token name
TOKEN_NAME=$(echo -n $2 | xxd -p)

# Query UTXOs
$CARDANO_CLI    query   utxo    \
    --address   $WALLET_ADDR    \
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
    if [ $TOKEN_AMOUNT -lt 0 ] && [ "$TOKEN_NAME" = "$(echo $IS_TOKEN | cut -d '.' -f2)" ]; then
        POLICY_ID=$(echo $IS_TOKEN | cut -d '.' -f1)
        AMOUNT=$(echo $UTXO | cut -d ' ' -f6)
        TOKEN_AMOUNT=$(expr $TOKEN_AMOUNT + $AMOUNT)
        TX_IN="$TX_IN --tx-in $TX_HASH#$TX_IX"
    fi
done < utxo/$1.utxo

# Get current slot to calculate validity period
MINUTES=$5
SLOT=$($CARDANO_CLI query   tip \
    $CARDANO_MAGIC  \
    |   sed -n  '6p'    \
    |   cut -d  ':' -f2 \
    |   tr  ',' ' ' \
    |   xargs)
INVALID_HEREAFTER=$(expr $SLOT + 60 \* $MINUTES)
echo "Current  slot  is  $SLOT"
echo "Burnable till slot $INVALID_HEREAFTER"

# Build transaction raw file
if [ $TOKEN_AMOUNT -gt 0 ]; then
    rm -f tokens/$1/$1.raw
    MIN_REQ_UTXO=$($CARDANO_CLI transaction build   $TX_IN  \
        --tx-out    $WALLET_ADDR+0+"$TOKEN_AMOUNT   $POLICY_ID.$TOKEN_NAME" \
        --mint  "-$3 $POLICY_ID.$TOKEN_NAME"    \
        --minting-script-file   nft/$1/$POLICY_NAME.script  \
        --invalid-hereafter $INVALID_HEREAFTER  \
        --witness-override  2   \
        --change-address    $WALLET_ADDR    \
        --out-file  nft/$1/$POLICY_NAME.$TOKEN_NAME.raw \
        $CARDANO_MAGIC  $CARDANO_ERA    2>&1)
    FEE=$($CARDANO_CLI  transaction build   $TX_IN  \
        --tx-out    $WALLET_ADDR+${MIN_REQ_UTXO##* }+"$TOKEN_AMOUNT $POLICY_ID.$TOKEN_NAME" \
        --mint  "-$3 $POLICY_ID.$TOKEN_NAME"    \
        --minting-script-file   nft/$1/$POLICY_NAME.script  \
        --invalid-hereafter $INVALID_HEREAFTER  \
        --witness-override  2   \
        --change-address    $WALLET_ADDR    \
        --out-file  nft/$1/$POLICY_NAME.$TOKEN_NAME.raw \
        $CARDANO_MAGIC  $CARDANO_ERA    2>&1)
    rm -f tokens/$1/$1.raw
    if [ ${FEE##* } -gt ${MIN_REQ_UTXO##* } ]; then
        $CARDANO_CLI    transaction build   $TX_IN  \
            --tx-out    $WALLET_ADDR+${FEE##* }+"$TOKEN_AMOUNT  $POLICY_ID.$TOKEN_NAME" \
            --mint  "-$3 $POLICY_ID.$TOKEN_NAME"    \
            --minting-script-file   nft/$1/$POLICY_NAME.script  \
            --invalid-hereafter $INVALID_HEREAFTER  \
            --witness-override  2   \
            --change-address    $WALLET_ADDR    \
            --out-file  nft/$1/$POLICY_NAME.$TOKEN_NAME.raw \
            $CARDANO_MAGIC  $CARDANO_ERA
    else
        $CARDANO_CLI    transaction build   $TX_IN  \
            --tx-out    $WALLET_ADDR+${MIN_REQ_UTXO##* }+"$TOKEN_AMOUNT $POLICY_ID.$TOKEN_NAME" \
            --mint  "-$3 $POLICY_ID.$TOKEN_NAME"    \
            --minting-script-file   nft/$1/$POLICY_NAME.script  \
            --invalid-hereafter $INVALID_HEREAFTER  \
            --witness-override  2   \
            --change-address    $WALLET_ADDR    \
            --out-file  nft/$1/$POLICY_NAME.$TOKEN_NAME.raw \
            $CARDANO_MAGIC  $CARDANO_ERA
    fi
else
    rm -f tokens/$1/$1.raw
    $CARDANO_CLI    transaction build   $TX_IN  \
        --mint  "-$3 $POLICY_ID.$TOKEN_NAME"    \
        --minting-script-file   nft/$1/$POLICY_NAME.script  \
        --invalid-hereafter $INVALID_HEREAFTER  \
        --witness-override  2   \
        --change-address    $WALLET_ADDR    \
        --out-file  nft/$1/$POLICY_NAME.$TOKEN_NAME.raw \
        $CARDANO_MAGIC  $CARDANO_ERA
fi

# View the transaction
$CARDANO_CLI    transaction view    \
    --tx-body-file  nft/$1/$POLICY_NAME.$TOKEN_NAME.raw

# Sign the transaction
rm -f nft/$1/$POLICY_NAME.$TOKEN_NAME.signed
$CARDANO_CLI    transaction sign    \
    --tx-body-file  nft/$1/$POLICY_NAME.$TOKEN_NAME.raw \
    --signing-key-file  wallets/$1/$1.skey  \
    --signing-key-file  nft/$1/$POLICY_NAME.skey    \
    --out-file  nft/$1/$POLICY_NAME.$TOKEN_NAME.signed  \
    $CARDANO_MAGIC

# Submit the transaction to the network
$CARDANO_CLI    transaction submit  \
    --tx-file   nft/$1/$POLICY_NAME.$TOKEN_NAME.signed  \
    $CARDANO_MAGIC

# Show the result tx hash
echo "\nTxHash:"
$CARDANO_CLI    transaction txid    \
    --tx-file   nft/$1/$POLICY_NAME.$TOKEN_NAME.signed
