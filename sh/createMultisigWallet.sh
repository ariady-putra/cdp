# Check the arguments
echo "MULTISIG wallet name is $1$2$3"

# Generate key hashes
KEYHASH1=$(cardano-cli-1-35-3   address key-hash    \
    --payment-verification-key-file wallets/$1/$1.vkey)
KEYHASH2=$(cardano-cli-1-35-3   address key-hash    \
    --payment-verification-key-file wallets/$2/$2.vkey)
KEYHASH3=$(cardano-cli-1-35-3   address key-hash    \
    --payment-verification-key-file wallets/$3/$3.vkey)

# Create wallet directory
mkdir -p wallets/$1$2$3
cd wallets/$1$2$3

# Create the multisig policy script file
echo "\
{\r
    \"type\": \"all\",\r
    \"scripts\":\r
    [\r
        {\r
            \"type\": \"sig\",\r
            \"keyHash\": \"$KEYHASH1\"\r
        },\r
        {\r
            \"type\": \"sig\",\r
            \"keyHash\": \"$KEYHASH2\"\r
        },\r
        {\r
            \"type\": \"sig\",\r
            \"keyHash\": \"$KEYHASH3\"\r
        }\r
    ]\r
}\
" > $1$2$3.multisig

# Create wallet address
cardano-cli-1-35-3  address build   \
    --payment-script-file   $1$2$3.multisig \
    --out-file  $1$2$3.addr \
    --testnet-magic 1

# Print info
echo "MULTISIG wallet created:"

# List the wallet directory files
ls

# Print the new wallet address
echo "Your MULTISIG wallet address is:"
cat $1$2$3.addr
