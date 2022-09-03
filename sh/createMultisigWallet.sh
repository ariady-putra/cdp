# Get env cfg
CARDANO_CLI="cardano-cli"
if test -f ~/cardano/cfg/cli.cardano; then
    CARDANO_CLI=$(cat ~/cardano/cfg/cli.cardano)
fi
CARDANO_MAGIC="--mainnet"
if test -f ~/cardano/cfg/magic.cardano; then
    CARDANO_MAGIC=$(cat ~/cardano/cfg/magic.cardano)
fi

# Check the arguments
echo "MULTISIG wallet name is $1$2$3"

# Generate key hashes
KEYHASH1=$($CARDANO_CLI address key-hash    \
    --payment-verification-key-file wallets/$1/$1.vkey)
KEYHASH2=$($CARDANO_CLI address key-hash    \
    --payment-verification-key-file wallets/$2/$2.vkey)
KEYHASH3=$($CARDANO_CLI address key-hash    \
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
$CARDANO_CLI    address build   \
    --payment-script-file   $1$2$3.multisig \
    --out-file  $1$2$3.addr \
    $CARDANO_MAGIC

# Print info
echo "MULTISIG wallet created:"

# List the wallet directory files
ls

# Print the new wallet address
echo "Your MULTISIG wallet address is:"
cat $1$2$3.addr
