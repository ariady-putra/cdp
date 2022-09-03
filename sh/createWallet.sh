# Get env cfg
CARDANO_CLI="cardano-cli"
if test -f ~/cardano/cfg/cli.cardano; then
    CARDANO_CLI=$(cat ~/cardano/cfg/cli.cardano)
fi
CARDANO_MAGIC="--mainnet"
if test -f ~/cardano/cfg/magic.cardano; then
    CARDANO_MAGIC=$(cat ~/cardano/cfg/magic.cardano)
fi

# Check the argument: walletname
echo "Wallet name is $1"

# Create wallet directory
mkdir -p wallets/$1
cd wallets/$1

# Create wallet payment keys
$CARDANO_CLI    address key-gen \
    --verification-key-file $1.vkey \
    --signing-key-file  $1.skey

# Create wallet stake keys
$CARDANO_CLI    stake-address   key-gen \
    --verification-key-file $1.vkey.stake   \
    --signing-key-file  $1.skey.stake

# Create wallet address
rm -f $1.addr
$CARDANO_CLI    address build   \
    --payment-verification-key-file $1.vkey \
    --stake-verification-key-file   $1.vkey.stake   \
    --out-file  $1.addr \
    $CARDANO_MAGIC

# Print info
echo "Wallet created:"

# List the wallet directory files
ls

# Print the new wallet address
echo "Your new wallet address is:"
cat $1.addr
