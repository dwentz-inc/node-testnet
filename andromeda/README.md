
<p align="center">
  <img width="270" height="auto" src="https://user-images.githubusercontent.com/118625308/218327952-9f4d1d75-43ee-4872-b384-4cfeefc4ff69.jpeg">
</p>

### Spesifikasi Hardware :
NODE  | CPU     | RAM      | SSD     |
| ------------- | ------------- | ------------- | -------- |
| Testnet | 4          | 8         | 120  |


### Install otomatis
```
wget -O andromeda.sh https://raw.githubusercontent.com/dwentz-inc/node-testnet/main/andromeda/andromeda.sh && chmod +x andromeda.sh && ./andromeda.sh
```
### Load variable ke system
```
source $HOME/.bash_profile
```
### Statesync
```
N/A
```
### Informasi node

* cek sync node
```
andromedad status 2>&1 | jq .SyncInfo
```
* cek log node
```
journalctl -fu andromedad -o cat
```
* cek node info
```
andromedad status 2>&1 | jq .NodeInfo
```
* cek validator info
```
andromedad status 2>&1 | jq .ValidatorInfo
```
* cek node id
```
andromedad tendermint show-node-id
```
### Membuat wallet
* wallet baru
```
andromedad keys add $WALLET
```
* recover wallet
```
andromedad keys add $WALLET --recover
```
* list wallet
```
andromedad keys list
```
* hapus wallet
```
andromedad keys delete $WALLET
```
### Simpan informasi wallet
```
ANDROMEDA_WALLET_ADDRESS=$(andromedad keys show $WALLET -a)
ANDROMEDA_VALOPER_ADDRESS=$(andromedad keys show $WALLET --bech val -a)
echo 'export ANDROMEDA_WALLET_ADDRESS='${ANDROMEDA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export ANDROMEDA_VALOPER_ADDRESS='${ANDROMEDA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Membuat validator
* cek balance
```
andromedad query bank balances $ANDROMEDA_WALLET_ADDRESS
```
* membuat validator
```
andromedad tx staking create-validator \
  --amount 100000uandr \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --identity "F57A71944DDA8C4B" \
  --website https://dwentz.xyz \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(andromedad tendermint show-validator) \
  --moniker $NODENAME \
  --gas=auto \
  --gas-adjustment=1.2 \
  --gas-prices=0.025uandr \
  --chain-id $ANDROMEDA_CHAIN_ID
```
* edit validator
```
andromedad tx staking edit-validator \
  --new-moniker="nama-node" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$ANDROMEDA_CHAIN_ID \
  --gas=auto \
  --fees=260000000uandr \
  --gas-adjustment=1.2 \
  --from=$WALLET
```
* unjail validator
```
andromedad tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$ANDROMEDA_CHAIN_ID \
  --fees=200000000uandr \
  --gas-adjustment=1.2 \
  --gas=auto
```
### Voting
```
andromedad tx gov vote 1 yes --from $WALLET --chain-id=$ANDROMEDA_CHAIN_ID --gas=auto --fees=2500000uandr
```
### Delegasi dan Rewards
* delegasi
```
andromedad tx staking delegate $ANDROMEDA_VALOPER_ADDRESS 1000000000000uandr --from=$WALLET --chain-id=$ANDROMEDA_CHAIN_ID --gas=auto --fees=250000uandr
```
* withdraw reward
```
andromedad tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$ANDROMEDA_CHAIN_ID --gas=auto --fees=2500000uandr
```
* withdraw reward beserta komisi
```
andromedad tx distribution withdraw-rewards $ANDROMEDA_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$ANDROMEDA_CHAIN_ID --gas=auto --fees=2500000uandr
```

### Hapus node
```
sudo systemctl stop  andromedad && \
sudo systemctl disable  andromedad && \
rm -rf /etc/systemd/system/andromedad.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf andromedad && \
rm -rf andromeda.sh && \
rm -rf .andromedad && \
rm -rf $(which andromedad)
```
