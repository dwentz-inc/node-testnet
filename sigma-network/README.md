<p align="center">
  <img width="270" height="auto" src="https://user-images.githubusercontent.com/108969749/202830107-d682de81-0c47-4f80-a4f1-d2d44f7492ea.png">
</p>

### Spesifikasi Hardware :
NODE  | CPU     | RAM      | SSD     |
| ------------- | ------------- | ------------- | -------- |
| Testnet | 4          | 8         | 200  |

### Install otomatis
```
wget -O sge.sh https://raw.githubusercontent.com/dwentz-inc/node-testnet/main/sigma-network/sge.sh && chmod +x sge.sh && ./sge.sh
```
### Load variable ke system
```
source $HOME/.bash_profile
```
### Statesync by #Polkachu
```
SNAP_RPC="https://saage-testnet-rpc.polkachu.com:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.sge/config/config.toml

sged tendermint unsafe-reset-all --home /root/.sge
systemctl restart sged && journalctl -u sged -f -o cat
```

### Informasi node

* cek sync node
```
sged status 2>&1 | jq .SyncInfo
```
* cek log node
```
journalctl -fu sged -o cat
```
* cek node info
```
sged status 2>&1 | jq .NodeInfo
```
* cek validator info
```
sged status 2>&1 | jq .ValidatorInfo
```
* cek node id
```
sged tendermint show-node-id
```
### Membuat wallet
* wallet baru
```
sged keys add $WALLET
```
* recover wallet
```
sged keys add $WALLET --recover
```
* list wallet
```
sged keys list
```
* hapus wallet
```
sged keys delete $WALLET
```
### Simpan informasi wallet
```
SGE_WALLET_ADDRESS=$(sged keys show $WALLET -a)
SGE_VALOPER_ADDRESS=$(sged keys show $WALLET --bech val -a)
echo 'export SGE_WALLET_ADDRESS='${SGE_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export SGE_VALOPER_ADDRESS='${SGE_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Membuat validator
* cek balance
```
sged query bank balances $SGE_WALLET_ADDRESS
```
* membuat validator
```
sged tx staking create-validator \
  --amount 50000000usge \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(sged tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $SGE_CHAIN_ID
```
* edit validator
```
sged tx staking edit-validator \
  --new-moniker="nama-node" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$SGE_CHAIN_ID \
  --from=$WALLET
```
* unjail validator
```
sged tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$SGE_CHAIN_ID \
  --gas=auto
```
### Voting
```
sged tx gov vote 1 yes --from $WALLET --chain-id=$SGE_CHAIN_ID --gees=250usge
```
### Delegasi dan Rewards
* delegasi
```
sged tx staking delegate $SGE_VALOPER_ADDRESS 1000000usge --from=$WALLET --chain-id=$SGE_CHAIN_ID --gas=auto --fees=250usge
```
* withdraw reward
```
sged tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$SGE_CHAIN_ID --gas=auto --fees=250usge
```
* withdraw reward beserta komisi
```
sged tx distribution withdraw-rewards $SGE_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$SGE_CHAIN_ID --fees=250usge
```

### Hapus node
```
sudo systemctl stop sged && \
sudo systemctl disable sged && \
rm /etc/systemd/system/sged.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf sge && \
rm -rf sge.sh && \
rm -rf .sge && \
rm -rf $(which sged)
```
