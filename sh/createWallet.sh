# Check the argument: walletname
echo "Wallet name is $1"

# Create wallet directory
mkdir -p wallets/$1
cd wallets/$1

# Create wallet payment keys
cardano-cli-1-35-3  address key-gen \
    --verification-key-file $1.vkey \
    --signing-key-file  $1.skey

# Create wallet stake keys
cardano-cli-1-35-3  stake-address   key-gen \
    --verification-key-file $1.vkey.stake   \
    --signing-key-file  $1.skey.stake

# Create wallet address
rm -f $1.addr
cardano-cli-1-35-3  address build   \
    --payment-verification-key-file $1.vkey \
    --stake-verification-key-file   $1.vkey.stake   \
    --out-file  $1.addr \
    --testnet-magic 1

# Print info
echo "Wallet created:"

# List the wallet directory files
ls

# Print the new wallet address
echo "Your new wallet address is:"
cat $1.addr
