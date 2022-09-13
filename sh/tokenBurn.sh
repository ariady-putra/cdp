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

# Create tokens directory
mkdir -p tokens/$1

# Generate key hashes
KEYHASH=$($CARDANO_CLI  address key-hash    \
    --payment-verification-key-file wallets/$1/$1.vkey)

# Create the token policy script file
echo "Script:"
# https://github.com/mallapurbharat/cardano-tx-sample/blob/main/native-tokens/1_Fungible_Token_Exercise.md#generate-the-policy
echo "\
{\r
    \"type\": \"sig\",\r
    \"keyHash\": \"$KEYHASH\"\r
}\
" > tokens/$1/$1.script
cat tokens/$1/$1.script

# Create the token policy ID
# https://github.com/mallapurbharat/cardano-tx-sample/blob/main/native-tokens/1_Fungible_Token_Exercise.md#asset-minting
POLICY_ID=$($CARDANO_CLI    transaction policyid    \
    --script-file   tokens/$1/$1.script)

# Generate Base16 token name
TOKEN_NAME=$(echo $2 | xxd -p)

# Query UTXOs
$CARDANO_CLI    query   utxo    \
    --address   $WALLET_ADDR    \
    $CARDANO_MAGIC  \
    |   tail    +3  \
    >   utxo/$1.utxo
TX_IN=""
TOKEN_AMOUNT=-$3
while read UTXO
do
    TX_HASH=$(echo  $UTXO | cut -d ' ' -f1)
    TX_IX=$(echo    $UTXO | cut -d ' ' -f2)
    
    IS_TOKEN=$(echo $UTXO | cut -d ' ' -f7)
    if ! [ $IS_TOKEN ]; then
        TX_IN="$TX_IN --tx-in $TX_HASH#$TX_IX"
    fi
    if [ "$IS_TOKEN" = "$POLICY_ID.$TOKEN_NAME" ]; then
        AMOUNT=$(echo $UTXO | cut -d ' ' -f6)
        TOKEN_AMOUNT=$(expr $TOKEN_AMOUNT + $AMOUNT)
        TX_IN="$TX_IN --tx-in $TX_HASH#$TX_IX"
    fi
done < utxo/$1.utxo

# Build transaction raw file
if [ $TOKEN_AMOUNT -gt 0 ]; then
    rm -f tokens/$1/$1.raw
    MIN_REQ_UTXO=$($CARDANO_CLI transaction build   $TX_IN  \
        --tx-out    $WALLET_ADDR+0+"$TOKEN_AMOUNT   $POLICY_ID.$TOKEN_NAME" \
        --mint  "-$3 $POLICY_ID.$TOKEN_NAME"    \
        --minting-script-file   tokens/$1/$1.script \
        --change-address    $WALLET_ADDR    \
        --out-file  tokens/$1/$1.raw    \
        $CARDANO_MAGIC  $CARDANO_ERA    2>&1)
    rm -f tokens/$1/$1.raw
    $CARDANO_CLI    transaction build   $TX_IN  \
        --tx-out    $WALLET_ADDR+${MIN_REQ_UTXO##* }+"$TOKEN_AMOUNT $POLICY_ID.$TOKEN_NAME" \
        --mint  "-$3 $POLICY_ID.$TOKEN_NAME"    \
        --minting-script-file   tokens/$1/$1.script \
        --change-address    $WALLET_ADDR    \
        --out-file  tokens/$1/$1.raw    \
        $CARDANO_MAGIC  $CARDANO_ERA
else
    rm -f tokens/$1/$1.raw
    MIN_REQ_UTXO=$($CARDANO_CLI transaction build   $TX_IN  \
        --mint  "-$3 $POLICY_ID.$TOKEN_NAME"    \
        --minting-script-file   tokens/$1/$1.script \
        --change-address    $WALLET_ADDR    \
        --out-file  tokens/$1/$1.raw    \
        $CARDANO_MAGIC  $CARDANO_ERA    2>&1)
    rm -f tokens/$1/$1.raw
    $CARDANO_CLI    transaction build   $TX_IN  \
        --mint  "-$3 $POLICY_ID.$TOKEN_NAME"    \
        --minting-script-file   tokens/$1/$1.script \
        --change-address    $WALLET_ADDR    \
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
