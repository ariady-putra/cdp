# Check the argument: walletname
echo "Wallet name is $1"

# Create wallet directory
mkdir wallets/$1
cd wallets/$1

# Create wallet keys
# cardano-cli-1-35-2 address key-gen --verification-key-file $1.vkey --signing-key-file $1.skey
cardano-cli-1-35-3 address key-gen --verification-key-file $1.vkey --signing-key-file $1.skey

# Create wallet address
# cardano-cli-1-35-2 address build --payment-verification-key-file $1.vkey --out-file $1.addr --testnet-magic 1097911063
cardano-cli-1-35-3 address build --payment-verification-key-file $1.vkey --out-file $1.addr --testnet-magic 2

# Print info
echo "Wallet created:"

# List wallets directory
ls

# Print the new wallet address
echo "Your new wallet address is:"
cat $1.addr
