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

# Query UTXOs
echo "$WALLET_ADDR:\n"
$CARDANO_CLI    query   utxo    \
    --address   $WALLET_ADDR    \
    $CARDANO_MAGIC  \
    |   tail    +3  \
    >   utxo/$1.utxo
TX_IN=""
while read UTXO
do
    TX_HASH=$(echo  $UTXO | cut -d ' ' -f1)
    TX_IX=$(echo    $UTXO | cut -d ' ' -f2)
    
    IS_TOKEN=$(echo $UTXO | cut -d ' ' -f8)
    if ! [ $IS_TOKEN ]; then
        TX_IN="$TX_IN --tx-in $TX_HASH#$TX_IX"
    fi
done < utxo/$1.utxo

# Populate other parameters
POLICY_NAME=$2
MINUTES=$3
NFT_NAME=$4
NFT_DESC=$5
NFT_IMG=$6
NFT_ID=$7
NFT_COUNT=$8

# Get current slot to calculate validity period
SLOT=$($CARDANO_CLI query   tip \
    $CARDANO_MAGIC  \
    |   sed -n  '6p'    \
    |   cut -d  ':' -f2 \
    |   tr  ',' ' ' \
    |   xargs)
INVALID_HEREAFTER=$(expr $SLOT + 60 \* $MINUTES)
echo "Current  slot  is  $SLOT"
echo "Mintable till slot $INVALID_HEREAFTER"

if [ ! -f nft/$1/$POLICY_NAME.script ]; then
    # Create wallet payment keys
    mkdir -p nft/$1
    $CARDANO_CLI    address key-gen \
        --verification-key-file nft/$1/$POLICY_NAME.vkey    \
        --signing-key-file  nft/$1/$POLICY_NAME.skey
    
    # Create wallet address
    rm -f nft/$1/$POLICY_NAME.addr
    $CARDANO_CLI    address build   \
        --payment-verification-key-file nft/$1/$POLICY_NAME.vkey    \
        --stake-verification-key-file   wallets/$1/$1.vkey.stake    \
        --out-file  nft/$1/$POLICY_NAME.addr    \
        $CARDANO_MAGIC
    
    # Generate key hashes
    KEYHASH=$($CARDANO_CLI  address key-hash    \
        --payment-verification-key-file nft/$1/$POLICY_NAME.vkey)
    
    # Create the policy script file
    echo "Script:"
    # https://github.com/input-output-hk/cardano-node/blob/c6b574229f76627a058a7e559599d2fc3f40575d/doc/reference/simple-scripts.md#multisignature-scripts
    echo "\
{\r
    \"type\": \"all\",\r
    \"scripts\":\r
    [\r
        {\r
            \"type\": \"before\",\r
            \"slot\": $INVALID_HEREAFTER\r
        },\r
        {\r
            \"type\": \"sig\",\r
            \"keyHash\": \"$KEYHASH\"\r
        }\r
    ]\r
}" > nft/$1/$POLICY_NAME.script
fi
cat nft/$1/$POLICY_NAME.script

# Create the token policy ID
POLICY_ID=$($CARDANO_CLI    transaction policyid    \
    --script-file   nft/$1/$POLICY_NAME.script)

# Generate Base16 token name
TOKEN_NAME=$(echo -n $NFT_NAME | xxd -p)

# Create the metadata json file
echo "Metadata:"
echo "\
{\r
    \"721\":\r
    {\r
        \"$POLICY_ID\":\r
        {\r
            \"$NFT_NAME\":\r
            {\r
                \"id\": $NFT_ID,\r
                \"name\": \"$NFT_NAME\",\r
                \"description\": \"$NFT_DESC\",\r
                \"image\": \"$NFT_IMG\"\r
            }\r
        }\r
    }\r
}" > nft/$1/$POLICY_NAME.$TOKEN_NAME
cat nft/$1/$POLICY_NAME.$TOKEN_NAME

# Build transaction raw file
rm -f nft/$1/$POLICY_NAME.$TOKEN_NAME.raw
MIN_REQ_UTXO=$($CARDANO_CLI transaction build   $TX_IN  \
    --tx-out    $WALLET_ADDR+0+"$NFT_COUNT  $POLICY_ID.$TOKEN_NAME" \
    --mint  "$NFT_COUNT $POLICY_ID.$TOKEN_NAME" \
    --minting-script-file   nft/$1/$POLICY_NAME.script  \
    --metadata-json-file    nft/$1/$POLICY_NAME.$TOKEN_NAME \
    --invalid-hereafter $INVALID_HEREAFTER  \
    --witness-override  2   \
    --change-address    $WALLET_ADDR    \
    --out-file  nft/$1/$POLICY_NAME.$TOKEN_NAME.raw \
    $CARDANO_MAGIC  $CARDANO_ERA    2>&1)
FEE=$($CARDANO_CLI  transaction build   $TX_IN  \
    --tx-out    $WALLET_ADDR+${MIN_REQ_UTXO##* }+"$NFT_COUNT    $POLICY_ID.$TOKEN_NAME" \
    --mint  "$NFT_COUNT $POLICY_ID.$TOKEN_NAME" \
    --minting-script-file   nft/$1/$POLICY_NAME.script  \
    --metadata-json-file    nft/$1/$POLICY_NAME.$TOKEN_NAME \
    --invalid-hereafter $INVALID_HEREAFTER  \
    --witness-override  2   \
    --change-address    $WALLET_ADDR    \
    --out-file  nft/$1/$POLICY_NAME.$TOKEN_NAME.raw \
    $CARDANO_MAGIC  $CARDANO_ERA    2>&1)

# Rebuild transaction raw file
rm -f nft/$1/$POLICY_NAME.$TOKEN_NAME.raw
if [ ${FEE##* } -gt ${MIN_REQ_UTXO##* } ]; then
    $CARDANO_CLI    transaction build   $TX_IN  \
        --tx-out    $WALLET_ADDR+${FEE##* }+"$NFT_COUNT $POLICY_ID.$TOKEN_NAME" \
        --mint  "$NFT_COUNT $POLICY_ID.$TOKEN_NAME" \
        --minting-script-file   nft/$1/$POLICY_NAME.script  \
        --metadata-json-file    nft/$1/$POLICY_NAME.$TOKEN_NAME \
        --invalid-hereafter $INVALID_HEREAFTER  \
        --witness-override  2   \
        --change-address    $WALLET_ADDR    \
        --out-file  nft/$1/$POLICY_NAME.$TOKEN_NAME.raw \
        $CARDANO_MAGIC  $CARDANO_ERA
else
    $CARDANO_CLI    transaction build   $TX_IN  \
        --tx-out    $WALLET_ADDR+${MIN_REQ_UTXO##* }+"$NFT_COUNT    $POLICY_ID.$TOKEN_NAME" \
        --mint  "$NFT_COUNT $POLICY_ID.$TOKEN_NAME" \
        --minting-script-file   nft/$1/$POLICY_NAME.script  \
        --metadata-json-file    nft/$1/$POLICY_NAME.$TOKEN_NAME \
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
