<p align="center">
  <img width="270" height="auto" src="https://user-images.githubusercontent.com/108969749/201577161-6ceb4b84-03f0-4161-b0d8-88d844fdd8ba.jpeg">
</p>

### Spesifikasi Hardware :
NODE  | CPU     | RAM      | SSD     |
| ------------- | ------------- | ------------- | -------- |
| Testnet | 6          | 16         | 256  |

### Install otomatis
```
wget -O gitopia.sh https://raw.githubusercontent.com/dwentz-inc/node-testnet/main/cosmos-gitopia/gitopia.sh && chmod +x gitopia.sh && ./gitopia.sh
```
### Load variable ke system
```
source $HOME/.bash_profile
```
### Statesync by #Polkachu
```

SNAP_RPC="https://gitopia-testnet-rpc.polkachu.com:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.gitopia/config/config.toml

gitopiad tendermint unsafe-reset-all --home /root/.gitopia
systemctl restart gitopiad && journalctl -u gitopiad -f -o cat
```
### Informasi node

* cek sync node
```
gitopiad status 2>&1 | jq .SyncInfo
```
* cek log node
```
journalctl -fu gitopiad -o cat
```
* cek node info
```
gitopiad status 2>&1 | jq .NodeInfo
```
* cek validator info
```
gitopiad status 2>&1 | jq .ValidatorInfo
```
* cek node id
```
gitopiad tendermint show-node-id
```
### Membuat wallet
* wallet baru
```
gitopiad keys add $WALLET
```
* recover wallet
```
gitopiad keys add $WALLET --recover
```
* list wallet
```
gitopiad keys list
```
* hapus wallet
```
gitopiad keys delete $WALLET
```
### Simpan informasi wallet
```
GITOPIA_WALLET_ADDRESS=$(gitopiad keys show $WALLET -a)
GITOPIA_VALOPER_ADDRESS=$(gitopiad keys show $WALLET --bech val -a)
echo 'export GITOPIA_WALLET_ADDRESS='${GITOPIA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export GITOPIA_VALOPER_ADDRESS='${GITOPIA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Membuat validator
* cek balance
```
gitopiad query bank balances $GITOPIA_WALLET_ADDRESS
```
* membuat validator
```
gitopiad tx staking create-validator \
  --amount 1000000utlore \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(gitopiad tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $GITOPIA_CHAIN_ID
```
* edit validator
```
gitopiad tx staking edit-validator \
  --new-moniker="nama-node" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$GITOPIA_CHAIN_ID \
  --from=$WALLET
```
* unjail validator
```
gitopiad tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$GITOPIA_CHAIN_ID \
  --gas=auto
```
### Voting
```
gitopiad tx gov vote 1 yes --from $WALLET --chain-id=$GITOPIA_CHAIN_ID
```
### Delegasi dan Rewards
* delegasi
```
gitopiad tx staking delegate $GITOPIA_VALOPER_ADDRESS 1000000ujkl --from=$WALLET --chain-id=GITOPIA_CHAIN_ID --gas=auto
```
* withdraw reward
```
gitopiad tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$GITOPIA_CHAIN_ID --gas=auto
```
* withdraw reward beserta komisi
```
gitopiad tx distribution withdraw-rewards $GITOPIA_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$GITOPIA_CHAIN_ID
```

### Hapus node
```
sudo systemctl stop gitopiad && \
sudo systemctl disable gitopiad && \
rm /etc/systemd/system/gitopiad.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf gitopia && \
rm -rf gitopia.sh && \
rm -rf .gitopia && \
rm -rf $(which gitopiad)
```
