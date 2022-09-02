# Get wallet address from wallet name
WALLET_ADDR=$(cat wallets/$1/$1.addr)

# Query UTXO
# TX_HASH_IX_AMOUNT=$(cardano-cli-1-35-2 query utxo --address $WALLET_ADDR --testnet-magic 1097911063 | sed -n 3p)
TX_HASH_IX_AMOUNT=$(cardano-cli-1-35-3 query utxo --address $WALLET_ADDR --testnet-magic 2 | sed -n 3p)

TX_HASH=$(echo $TX_HASH_IX_AMOUNT | cut -d ' ' -f1)
TX_IX=$(echo $TX_HASH_IX_AMOUNT | cut -d ' ' -f2)
AMOUNT=$(echo $TX_HASH_IX_AMOUNT | cut -d ' ' -f3)

# Write metadata-json-file
mkdir -p metadata/$1
echo "$2" > metadata/$1/$1.json

# Create transaction draft
rm -f metadata/$1/$1.draft
# cardano-cli-1-35-2	transaction	build-raw	\
cardano-cli-1-35-3	transaction	build-raw	\
	--babbage-era		\
	--tx-in	$TX_HASH#$TX_IX	\
	--tx-out	$WALLET_ADDR+0	\
	--metadata-json-file	metadata/$1/$1.json	\
	--fee	0	\
	--out-file	metadata/$1/$1.draft

# Query protocol-parameters
rm -f protocol/$1.params
# cardano-cli-1-35-2	query	protocol-parameters	\
cardano-cli-1-35-3	query	protocol-parameters	\
	--out-file	protocol/$1.params	\
	--testnet-magic	2
	# --testnet-magic	1097911063

# Calculate fee
# FEE=$(cardano-cli-1-35-2	transaction	calculate-min-fee	\
FEE=$(cardano-cli-1-35-3	transaction	calculate-min-fee	\
	--tx-body-file	metadata/$1/$1.draft	\
	--tx-in-count	1	\
	--tx-out-count	1	\
	--witness-count	1	\
	--byron-witness-count	0	\
	--protocol-params-file	protocol/$1.params	\
	--testnet-magic	2  |   cut -d  ' ' -f1)
	# --testnet-magic	1097911063  |   cut -d  ' ' -f1)

# Rebuild transaction draft
rm -f metadata/$1/$1.draft
# cardano-cli-1-35-2	transaction	build-raw	\
cardano-cli-1-35-3	transaction	build-raw	\
	--babbage-era		\
	--tx-in	$TX_HASH#$TX_IX	\
	--tx-out	$WALLET_ADDR+$(expr $AMOUNT - $FEE)	\
	--metadata-json-file	metadata/$1/$1.json	\
	--fee	$FEE	\
	--out-file	metadata/$1/$1.draft

# Sign transaction draft
rm -f metadata/$1/$1.signed
# cardano-cli-1-35-2	transaction	sign	\
cardano-cli-1-35-3	transaction	sign	\
	--tx-body-file	metadata/$1/$1.draft	\
	--signing-key-file	wallets/$1/$1.skey	\
	--out-file	metadata/$1/$1.signed	\
	--testnet-magic	2
	# --testnet-magic	1097911063

# Submit the transaction
# cardano-cli-1-35-2	transaction	submit	\
cardano-cli-1-35-3	transaction	submit	\
	--tx-file	metadata/$1/$1.signed	\
	--testnet-magic	2
	# --testnet-magic	1097911063
