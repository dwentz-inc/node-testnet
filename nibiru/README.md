
<p align="center">
  <img width="270" height="auto" src="https://user-images.githubusercontent.com/118625308/221603003-64c300cd-6980-418e-9c48-bcc1937664f7.jpeg">
</p>

### Spesifikasi Hardware :
NODE  | CPU     | RAM      | SSD     |
| ------------- | ------------- | ------------- | -------- |
| Testnet | 4          | 8         | 120  |


### Install otomatis
```
wget -O nibiru.sh https://raw.githubusercontent.com/dwentz-inc/node-testnet/main/nibiru/nibiru.sh && chmod +x nibiru.sh && ./nibiru.sh
```
### Load variable ke system
```
source $HOME/.bash_profile
```
### StateSync by #Roman
```
SNAP_RPC=65.108.199.120:61757 && \
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash) && \
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
```
```
sudo systemctl stop nibid && nibid tendermint unsafe-reset-all --home $HOME/.nibid --keep-addr-book
```
```
peers="2479ff4d8c0918b95da280319b179f016b5db814@65.108.199.120:61756"
sed -i.bak -e  "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.nibid/config/config.toml
```
```
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.nibid/config/config.toml
```
```
curl -o - -L https://anode.team/Nibiru/test/anode.team_nibiru_wasm.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.nibid/data
```
```
sudo systemctl restart nibid && journalctl -fu nibid -o cat
```
### Informasi node

* cek sync node
```
nibid status 2>&1 | jq .SyncInfo
```
* cek log node
```
journalctl -fu nibid -o cat
```
* cek node info
```
nibid status 2>&1 | jq .NodeInfo
```
* cek validator info
```
nibid status 2>&1 | jq .ValidatorInfo
```
* cek node id
```
nibid tendermint show-node-id
```
### Membuat wallet
* wallet baru
```
nibid keys add $WALLET
```
* recover wallet
```
nibid keys add $WALLET --recover
```
* list wallet
```
nibid keys list
```
* hapus wallet
```
nibid keys delete $WALLET
```
### Simpan informasi wallet
```
NIBIRU_WALLET_ADDRESS=$(nibid keys show $WALLET -a)
NIBIRU_VALOPER_ADDRESS=$(nibid keys show $WALLET --bech val -a)
echo 'export NIBIRU_WALLET_ADDRESS='${NIBIRU_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export NIBIRU_VALOPER_ADDRESS='${NIBIRU_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Membuat validator
* cek balance
```
nibid query bank balances $NIBIRU_WALLET_ADDRESS
```
* membuat validator
```
nibid tx staking create-validator \
  --amount 1000000000000unibi \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(nibid tendermint show-validator) \
  --moniker $NODENAME \
  --gas=auto \
  --gas-adjustment=1.2 \
  --gas-prices=0.025unibi \
  --chain-id $NIBIRU_CHAIN_ID
```
* edit validator
```
nibid tx staking edit-validator \
  --new-moniker="nama-node" \
  --identity="F57A71944DDA8C4B" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$NIBIRU_CHAIN_ID \
  --gas=auto \
  --fees=2000unibi \
  --gas-adjustment=1.2 \
  --from=$WALLET
```
* unjail validator
```
nibid tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$NIBIRU_CHAIN_ID \
  --fees=2000unibi \
  --gas-adjustment=1.2 \
  --gas=auto
```
### Voting
```
nibid tx gov vote 1 yes --from $WALLET --chain-id=$NIBIRU_CHAIN_ID --gas=auto --fees=2500000unibi
```
### Delegasi dan Rewards
* delegasi
```
nibid tx staking delegate $NIBIRU_VALOPER_ADDRESS 1000000000000unibi --from=$WALLET --chain-id=$NIBIRU_CHAIN_ID --gas=auto --fees=250000unibi
```
* withdraw reward
```
nibid tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$NIBIRU_CHAIN_ID --gas=auto --fees=2500000unibi
```
* withdraw reward beserta komisi
```
nibid tx distribution withdraw-rewards $NIBIRU_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$NIBIRU_CHAIN_ID --gas=auto --fees=2500000unibi
```

### Hapus node
```
sudo systemctl stop  nibid && \
sudo systemctl disable  nibid && \
rm /etc/systemd/system/ nibid.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf  nibiru && \
rm -rf nibiru.sh && \
rm -rf .nibid && \
rm -rf $(which nibid)
```
