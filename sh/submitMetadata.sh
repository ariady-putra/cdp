# echo "$1"
# echo "$2"

# Get wallet address from wallet name
WALLET_ADDR=$(cat wallets/$1/$1.addr)
# echo "$WALLET_ADDR"

# Query UTXO
TX_HASH_IX_AMOUNT=$(cardano-cli-1-35-2 query utxo --address $WALLET_ADDR --testnet-magic 1097911063 | sed -n 3p)
# echo "$TX_HASH_IX_AMOUNT"

TX_HASH=$(echo $TX_HASH_IX_AMOUNT | cut -d ' ' -f1)
TX_IX=$(echo $TX_HASH_IX_AMOUNT | cut -d ' ' -f2)
AMOUNT=$(echo $TX_HASH_IX_AMOUNT | cut -d ' ' -f3)
# echo "$TX_HASH#$TX_IX"
# echo "$AMOUNT"

# Write metadata-json-file
rm -rf metadata/$1
mkdir metadata/$1
echo "$2" > metadata/$1/$1.json

# Create transaction draft
cardano-cli-1-35-2	transaction	build-raw	\
	--babbage-era		\
	--tx-in	$TX_HASH#$TX_IX	\
	--tx-out	$WALLET_ADDR+0	\
	--metadata-json-file	metadata/$1/$1.json	\
	--fee	0	\
	--out-file	metadata/$1/$1.draft
# cat metadata/$1/$1.draft

# Query protocol-parameters
cardano-cli-1-35-2	query	protocol-parameters	\
	--out-file	protocol/$1.params	\
	--testnet-magic	1097911063
# cat protocol/$1.params

# Calculate fee
FEE=$(cardano-cli-1-35-2	transaction	calculate-min-fee	\
	--tx-body-file	metadata/$1/$1.draft	\
	--tx-in-count	1	\
	--tx-out-count	1	\
	--witness-count	1	\
	--byron-witness-count	0	\
	--protocol-params-file	protocol/$1.params	\
	--testnet-magic	1097911063  |   tr  -s  " Lovelace"  " ")
# echo "$FEE"

# Rebuild transaction draft
cardano-cli-1-35-2	transaction	build-raw	\
	--babbage-era		\
	--tx-in	$TX_HASH#$TX_IX	\
	--tx-out	$WALLET_ADDR+$(expr $AMOUNT - $FEE)	\
	--metadata-json-file	metadata/$1/$1.json	\
	--fee	$FEE	\
	--out-file	metadata/$1/$1.draft
# cat metadata/$1/$1.draft

# Sign transaction draft
cardano-cli-1-35-2	transaction	sign	\
	--tx-body-file	metadata/$1/$1.draft	\
	--signing-key-file	wallets/$1/$1.skey	\
	--out-file	metadata/$1/$1.signed	\
	--testnet-magic	1097911063
# cat metadata/$1/$1.signed

# Submit the transaction
cardano-cli-1-35-2	transaction	submit	\
	--tx-file	metadata/$1/$1.signed	\
	--testnet-magic	1097911063
