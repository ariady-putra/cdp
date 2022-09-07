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
AMOUNT=0
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

# Write metadata-json-file
mkdir -p metadata/$1
echo $2 > metadata/$1/$1.json

# Create transaction draft
rm -f metadata/$1/$1.draft
$CARDANO_CLI    transaction build-raw   $TX_IN  \
	--tx-out    $WALLET_ADDR+0  \
	--metadata-json-file    metadata/$1/$1.json \
	--fee   0   \
	--out-file  metadata/$1/$1.draft

# Query protocol-parameters
rm -f protocol/$1.params
$CARDANO_CLI    query   protocol-parameters \
	--out-file  protocol/$1.params  \
	$CARDANO_MAGIC

# Calculate fee
FEE=$($CARDANO_CLI  transaction calculate-min-fee   \
	--tx-body-file  metadata/$1/$1.draft    \
	--tx-in-count   $IN_COUNT   \
	--tx-out-count  1   \
	--witness-count 1   \
	--byron-witness-count   0   \
	--protocol-params-file  protocol/$1.params  \
	$CARDANO_MAGIC  |   cut -d  ' ' -f1)

# Rebuild transaction draft
rm -f metadata/$1/$1.draft
$CARDANO_CLI    transaction build-raw   $TX_IN  \
	--tx-out    $WALLET_ADDR+$(expr $AMOUNT - $FEE) \
	--metadata-json-file    metadata/$1/$1.json \
	--fee   $FEE    \
	--out-file  metadata/$1/$1.draft

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
