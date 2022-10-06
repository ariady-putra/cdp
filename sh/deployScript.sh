# Get env cfg
CARDANO_CLI="cardano-cli"
if test -f ~/cardano/cfg/cli.cardano; then
    CARDANO_CLI=$(cat ~/cardano/cfg/cli.cardano)
fi
CARDANO_MAGIC="--mainnet"
if test -f ~/cardano/cfg/magic.cardano; then
    CARDANO_MAGIC=$(cat ~/cardano/cfg/magic.cardano)
fi

# Create script address
rm -f $1.addr
$CARDANO_CLI    address build   \
    --payment-script-file $1  \
    --out-file  $1.addr \
    $CARDANO_MAGIC

# Print the script address
echo "Your script address is:"
cat $1.addr
