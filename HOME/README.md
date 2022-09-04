## This is a sample of `HOME` directory
The shell scripts ([`runcpreprod.sh`](runcpreprod.sh), [`runcpreview.sh`](runcpreview.sh), and [`runct.sh`](runct.sh)) will write some configuration files when executed, which then will be read by the [`cdp`](../../../) Node.js web app.<br/><br/>
The folder `.local/share/applications/` contains the desktop/application shortcuts pointing to the aforementioned executable shell scripts, where `.local/bin/` contains various versions of `cardano-node` and `cardano-cli` (not included here, please refer to [input-output-hk/cardano-node](https://github.com/input-output-hk/cardano-node)).

### System configurations documentation
#### `~/.local/bin/`
List of related files in the directory:
<pre>
<font color="#34E2E2"><b>cardano-cli</b></font>
<font color="#8AE234"><b>cardano-cli-1-35-2</b></font>
<font color="#8AE234"><b>cardano-cli-1-35-3</b></font>
<font color="#34E2E2"><b>cardano-node</b></font>
<font color="#8AE234"><b>cardano-node-1-35-2</b></font>
<font color="#8AE234"><b>cardano-node-1-35-3</b></font>
</pre>
<font color="#34E2E2"><b>cardano-cli</b></font> and <font color="#34E2E2"><b>cardano-node</b></font> are symlinks created by [`runcpreprod.sh`](runcpreprod.sh) or [`runcpreview.sh`](runcpreview.sh) or [`runct.sh`](runct.sh).

#### `~/.bashrc`
This is not required for the project, it's just for documentation.
```bash
source <(cardano-node-1-35-2 --bash-completion-script `which cardano-node-1-35-2`)
source <(cardano-cli-1-35-2 --bash-completion-script `which cardano-cli-1-35-2`)

source <(cardano-node-1-35-3 --bash-completion-script `which cardano-node-1-35-3`)
source <(cardano-cli-1-35-3 --bash-completion-script `which cardano-cli-1-35-3`)

source <(cardano-node --bash-completion-script `which cardano-node`)
source <(cardano-cli --bash-completion-script `which cardano-cli`)

alias cardano-node=$(eval 'cat ~/cardano/cfg/node.cardano')
alias cardano-cli=$(eval 'cat ~/cardano/cfg/cli.cardano')

CARDANO_MAGIC=$(eval 'cat ~/cardano/cfg/magic.cardano')
alias tipc='cardano-cli query tip $CARDANO_MAGIC'

alias runct='cardano-node-1-35-2 run \
    --topology ~/cardano-src/cardano-node/configuration/cardano/testnet-topology.json \
    --database-path ~/cardano/db/cardano-testnet \
    --socket-path ~/cardano/node.socket \
    --host-addr 0.0.0.0 \
    --port 60514 \
    --config ~/cardano-src/cardano-node/configuration/cardano/testnet-config.json'
alias tipct='cardano-cli-1-35-2 query tip --testnet-magic 1097911063'

alias runcpreprod='cardano-node-1-35-3 run \
    --topology ~/cardano/src/cardano-node/configuration/cardano/preprod-topology.json \
    --database-path ~/cardano/db/cardano-preprod \
    --socket-path ~/cardano/node.socket \
    --host-addr 0.0.0.0 \
    --port 13531 \
    --config ~/cardano/src/cardano-node/configuration/cardano/preprod-config.json'
alias tipcpreprod='cardano-cli-1-35-3 query tip --testnet-magic 1'

alias runcpreview='cardano-node-1-35-3 run \
    --topology ~/cardano/src/cardano-node/configuration/cardano/preview-topology.json \
    --database-path ~/cardano/db/cardano-preview \
    --socket-path ~/cardano/node.socket \
    --host-addr 0.0.0.0 \
    --port 13532 \
    --config ~/cardano/src/cardano-node/configuration/cardano/preview-config.json'
alias tipcpreview='cardano-cli-1-35-3 query tip --testnet-magic 2'
```
**source** must be done before the shadowing **alias**.
