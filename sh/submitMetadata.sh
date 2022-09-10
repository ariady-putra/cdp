# Get env cfg
CARDANO_CLI="cardano-cli"
if test -f ~/cardano/cfg/cli.cardano; then
    CARDANO_CLI=$(cat ~/cardano/cfg/cli.cardano)
fi
CARDANO_MAGIC="--mainnet"
if test -f ~/cardano/cfg/magic.cardano; then
    CARDANO_MAGIC=$(cat ~/cardano/cfg/magic.cardano)
fi

# Get wallet address from wallet name
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
    TX_HASH=$(echo $UTXO | cut -d ' ' -f1)
    TX_IX=$(echo $UTXO | cut -d ' ' -f2)
    TX_AMOUNT=$(echo $UTXO | cut -d ' ' -f3)
    TX_IN="$TX_IN --tx-in $TX_HASH#$TX_IX"
done < utxo/$1.utxo

# Write metadata-json-file
mkdir -p metadata/$1
echo $2 > metadata/$1/$1.json

# Build transaction raw file
mkdir -p transfers/$1
rm -f transfers/$1/$1.raw
$CARDANO_CLI    transaction build   $TX_IN  \
    --metadata-json-file    metadata/$1/$1.json $3  \
    --change-address    $WALLET_ADDR    \
    --out-file  metadata/$1/$1.draft    \
    $CARDANO_MAGIC  $CARDANO_ERA

# View the transaction
$CARDANO_CLI    transaction view    \
    --tx-body-file  metadata/$1/$1.draft

# Sign transaction draft
rm -f metadata/$1/$1.signed
$CARDANO_CLI    transaction sign    \
	--tx-body-file  metadata/$1/$1.draft    \
	--signing-key-file  wallets/$1/$1.skey  \
	--out-file  metadata/$1/$1.signed   \
	$CARDANO_MAGIC

# Submit the transaction to the network
$CARDANO_CLI    transaction submit  \
	--tx-file   metadata/$1/$1.signed   \
	$CARDANO_MAGIC

# Show the result tx hash
echo "\nTxHash:"
$CARDANO_CLI    transaction txid    \
    --tx-file   metadata/$1/$1.signed
