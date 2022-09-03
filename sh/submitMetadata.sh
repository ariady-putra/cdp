# Get wallet address from wallet name
WALLET_ADDR=$(cat wallets/$1/$1.addr)

# Query UTXOs
cardano-cli-1-35-3  query   utxo    \
    --address   $WALLET_ADDR    \
    --testnet-magic 1   \
    |   tail    +3  \
    >   utxo/$1.utxo
TX_IN=""
AMOUNT=0
IN_COUNT=0;
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
echo "$2" > metadata/$1/$1.json

# Create transaction draft
rm -f metadata/$1/$1.draft
cardano-cli-1-35-3  transaction build-raw   $TX_IN  \
	--tx-out    $WALLET_ADDR+0  \
	--metadata-json-file    metadata/$1/$1.json \
	--fee   0   \
	--out-file  metadata/$1/$1.draft

# Query protocol-parameters
rm -f protocol/$1.params
cardano-cli-1-35-3  query   protocol-parameters \
	--out-file  protocol/$1.params  \
	--testnet-magic 1

# Calculate fee
FEE=$(cardano-cli-1-35-3    transaction calculate-min-fee   \
	--tx-body-file  metadata/$1/$1.draft    \
	--tx-in-count   $IN_COUNT   \
	--tx-out-count  1   \
	--witness-count 1   \
	--byron-witness-count   0   \
	--protocol-params-file  protocol/$1.params  \
	--testnet-magic 1   |   cut -d  ' ' -f1)

# Rebuild transaction draft
rm -f metadata/$1/$1.draft
cardano-cli-1-35-3  transaction build-raw   $TX_IN  \
	--tx-out    $WALLET_ADDR+$(expr $AMOUNT - $FEE) \
	--metadata-json-file    metadata/$1/$1.json \
	--fee   $FEE    \
	--out-file  metadata/$1/$1.draft

# Sign transaction draft
rm -f metadata/$1/$1.signed
cardano-cli-1-35-3  transaction sign    \
	--tx-body-file  metadata/$1/$1.draft    \
	--signing-key-file  wallets/$1/$1.skey  \
	--out-file  metadata/$1/$1.signed   \
	--testnet-magic 1

# Submit the transaction
cardano-cli-1-35-3  transaction submit  \
	--tx-file   metadata/$1/$1.signed   \
	--testnet-magic 1
