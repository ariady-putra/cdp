# Get env cfg
CARDANO_CLI="cardano-cli"
if test -f ~/cardano/cfg/cli.cardano; then
    CARDANO_CLI=$(cat ~/cardano/cfg/cli.cardano)
fi
CARDANO_MAGIC="--mainnet"
if test -f ~/cardano/cfg/magic.cardano; then
    CARDANO_MAGIC=$(cat ~/cardano/cfg/magic.cardano)
fi

# Set wallet by name or address
WALLET=$1
if test -f wallets/$1/$1.addr; then
    WALLET=$(cat wallets/$1/$1.addr)
fi

# Query UTXOs
$CARDANO_CLI    query   utxo    \
    --address   $WALLET \
    $CARDANO_MAGIC
