
<p align="center">
  <img width="270" height="auto" src="https://user-images.githubusercontent.com/118625308/223598826-bf4ab4f2-7db5-4655-853c-3b6200a22840.png">
</p>

### Spesifikasi Hardware :
NODE  | CPU     | RAM      | SSD     |
| ------------- | ------------- | ------------- | -------- |
| Testnet | 4          | 8         | 120  |


### Install otomatis
```
wget -O ojo.sh https://raw.githubusercontent.com/dwentz-inc/node-testnet/main/ojo/ojo.sh && chmod +x ojo.sh && ./ojo.sh
```
### Load variable ke system
```
source $HOME/.bash_profile
```
### Statesync
```

sudo systemctl stop ojod
ojod tendermint unsafe-reset-all --home $HOME/.ojo --keep-addr-book 

STATE_SYNC_RPC="http://207.180.243.64:36657"

LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  -e "s|^persistent_peers *=.*|persistent_peers = \"$STATE_SYNC_PEER\"|" \
  $HOME/.ojo/config/config.toml
  
 #Reboot
sudo systemctl restart ojod && sudo journalctl -u ojod -f
```
### Informasi node

* cek sync node
```
ojod status 2>&1 | jq .SyncInfo
```
* cek log node
```
journalctl -fu ojod -o cat
```
* cek node info
```
ojod status 2>&1 | jq .NodeInfo
```
* cek validator info
```
ojod status 2>&1 | jq .ValidatorInfo
```
* cek node id
```
ojod tendermint show-node-id
```
### Membuat wallet
* wallet baru
```
ojod keys add $WALLET
```
* recover wallet
```
ojod keys add $WALLET --recover
```
* list wallet
```
ojod keys list
```
* hapus wallet
```
ojod keys delete $WALLET
```
### Simpan informasi wallet
```
OJO_WALLET_ADDRESS=$(ojod keys show $WALLET -a)
OJO_VALOPER_ADDRESS=$(ojod keys show $WALLET --bech val -a)
echo 'export OJO_WALLET_ADDRESS='${OJO_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export OJO_VALOPER_ADDRESS='${OJO_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Membuat validator
* cek balance
```
ojod query bank balances $OJO_WALLET_ADDRESS
```
* membuat validator
```
ojod tx staking create-validator \
  --amount 100000uojo \
  --from $WALLET \
  --commission-max-change-rate "0.02" \
  --commission-max-rate "0.2" \
  --identity "F57A71944DDA8C4B" \
  --website https://dwentz.xyz \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(ojod tendermint show-validator) \
  --moniker $NODENAME \
  --gas=auto \
  --gas-adjustment=1.2 \
  --gas-prices=0.025uojo \
  --chain-id $OJO_CHAIN_ID
```
* edit validator
```
ojod tx staking edit-validator \
  --new-moniker="nama-node" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$OJO_CHAIN_ID \
  --gas=auto \
  --fees=10uojo \
  --gas-adjustment=1.2 \
  --from=$WALLET
```
* unjail validator
```
ojod tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$OJO_CHAIN_ID \
  --fees=10uojo \
  --gas-adjustment=1.2 \
  --gas=auto
```
### Voting
```
ojod tx gov vote 1 yes --from $WALLET --chain-id=$OJO_CHAIN_ID --gas=auto --fees=25uojo
```
### Delegasi dan Rewards
* delegasi
```
ojod tx staking delegate $OJO_VALOPER_ADDRESS 1000000000000uojo --from=$WALLET --chain-id=$OJO_CHAIN_ID --gas=auto --fees=25uojo
```
* withdraw reward
```
ojod tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$OJO_CHAIN_ID --gas=auto --fees=25uojo
```
* withdraw reward beserta komisi
```
ojod tx distribution withdraw-rewards $OJO_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$OJO_CHAIN_ID --gas=auto --fees=25uojo
```

### Hapus node
```
sudo systemctl stop  ojod && \
sudo systemctl disable  ojod && \
rm -rf /etc/systemd/system/ojod.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf ojo && \
rm -rf ojo.sh && \
rm -rf .ojo && \
rm -rf $(which ojod)
```
