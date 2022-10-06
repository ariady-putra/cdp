# Get env cfg
CARDANO_CLI="cardano-cli"
if test -f ~/cardano/cfg/cli.cardano; then
    CARDANO_CLI=$(cat ~/cardano/cfg/cli.cardano)
fi
CARDANO_MAGIC="--mainnet"
if test -f ~/cardano/cfg/magic.cardano; then
    CARDANO_MAGIC=$(cat ~/cardano/cfg/magic.cardano)
fi
CARDANO_ERA=""
if test -f ~/cardano/cfg/era.cardano; then
    CARDANO_ERA=$(cat ~/cardano/cfg/era.cardano)
fi

# Get wallet addresses from wallet names
REDEEMER=$(cat wallets/$1/$1.addr)

# Generate key hashes
KEYHASH=$($CARDANO_CLI  address key-hash    \
    --payment-verification-key-file wallets/$1/$1.vkey)

# Query protocol-parameters
rm -f protocol/$1.params
$CARDANO_CLI    query   protocol-parameters \
    --out-file  protocol/$1.params  \
    $CARDANO_MAGIC

# Set validity period
INVALID_BEFORE=""
if [ $7 -gt 0 ]; then
    INVALID_BEFORE="--invalid-before $7"
fi
INVALID_HEREAFTER=""
if [ $8 -gt 0 ]; then
    INVALID_HEREAFTER="--invalid-hereafter $8"
fi

# Build transaction raw file
mkdir -p transfers/$1
rm -f transfers/$1/$1.raw
$CARDANO_CLI    transaction   build               \
    --tx-in                 $2                    \
    --tx-in-collateral      $3                    \
    --tx-in-script-file     $4                    \
    --tx-in-datum-file      $5                    \
    --tx-in-redeemer-file   $6                    \
    --tx-out                $REDEEMER+$9          \
    --required-signer-hash  $KEYHASH              \
    --protocol-params-file  protocol/$1.params    \
    --change-address        $10                   \
    --out-file              transfers/$1/$1.raw   \
    $CARDANO_MAGIC $INVALID_BEFORE $INVALID_HEREAFTER $CARDANO_ERA

# View the transaction
$CARDANO_CLI    transaction view    \
    --tx-body-file  transfers/$1/$1.raw

# Sign the transaction
rm -f transfers/$1/$1.signed
$CARDANO_CLI    transaction sign    \
    --tx-body-file  transfers/$1/$1.raw \
    --signing-key-file  wallets/$1/$1.skey  \
    --out-file  transfers/$1/$1.signed  \
    $CARDANO_MAGIC

# Submit the transaction to the network
$CARDANO_CLI    transaction submit  \
    --tx-file   transfers/$1/$1.signed  \
    $CARDANO_MAGIC

# Show the result tx hash
echo "\nTxHash:"
$CARDANO_CLI    transaction txid    \
    --tx-file   transfers/$1/$1.signed
