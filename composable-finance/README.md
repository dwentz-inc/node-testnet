
<p align="center">
  <img width="270" height="auto" src="https://github.com/dwentz-inc/node-testnet/assets/118625308/9c4a0f12-b400-45ec-b61d-4d9c49a6d36f">
</p>

### Spesifikasi Hardware :
NODE  | CPU     | RAM      | SSD     |
| ------------- | ------------- | ------------- | -------- |
| Testnet | 4          | 8         | 120  |


### Install otomatis
```
wget -O banksy.sh https://raw.githubusercontent.com/dwentz-inc/node-testnet/main/composable-finance/banksy.sh && chmod +x banksy.sh && ./banksy.sh
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
banksyd status 2>&1 | jq .SyncInfo
```
* cek log node
```
journalctl -fu banksyd -o cat
```
* cek node info
```
banksyd status 2>&1 | jq .NodeInfo
```
* cek validator info
```
banksyd status 2>&1 | jq .ValidatorInfo
```
* cek node id
```
banksyd tendermint show-node-id
```
### Membuat wallet
* wallet baru
```
banksyd keys add $WALLET
```
* recover wallet
```
banksyd keys add $WALLET --recover
```
* list wallet
```
banksyd keys list
```
* hapus wallet
```
banksyd keys delete $WALLET
```
### Simpan informasi wallet
```
BANKSY_WALLET_ADDRESS=$(banksyd keys show $WALLET -a)
BANKSY_VALOPER_ADDRESS=$(banksyd keys show $WALLET --bech val -a)
echo 'export BANKSY_WALLET_ADDRESS='${BANKSY_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export BANKSY_VALOPER_ADDRESS='${BANKSY_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Membuat validator
* cek balance
```
banksyd query bank balances $BANKSY_WALLET_ADDRESS
```
* membuat validator
```
banksyd tx staking create-validator \
  --amount 10000000upica \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --identity "F57A71944DDA8C4B" \
  --website https://dwentz.xyz \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(banksyd tendermint show-validator) \
  --moniker $NODENAME \
  --gas=auto \
  --gas-adjustment=1.2 \
  --gas-prices=0.00upica \
  --chain-id $BANKSY_CHAIN_ID
```
* edit validator
```
banksyd tx staking edit-validator \
  --new-moniker="nama-node" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$BANKSY_CHAIN_ID \
  --gas=auto \
  --fees=260000000upica \
  --gas-adjustment=1.2 \
  --from=$WALLET
```
* unjail validator
```
banksyd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$BANKSY_CHAIN_ID \
  --fees=200000000upica \
  --gas-adjustment=1.2 \
  --gas=auto
```
### Voting
```
banksyd tx gov vote 1 yes --from $WALLET --chain-id=$BANKSY_CHAIN_ID --gas=auto --fees=2500000upica
```
### Delegasi dan Rewards
* delegasi
```
banksyd tx staking delegate $BANKSY_VALOPER_ADDRESS 1000000000000upica --from=$WALLET --chain-id=$BANKSY_CHAIN_ID --gas=auto --fees=250000upica
```
* withdraw reward
```
banksyd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$BANKSY_CHAIN_ID --gas=auto --fees=2500000upica
```
* withdraw reward beserta komisi
```
banksyd tx distribution withdraw-rewards $BANKSY_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$BANKSY_CHAIN_ID --gas=auto --fees=2500000upica
```

### Hapus node
```
sudo systemctl stop  banksyd && \
sudo systemctl disable  banksyd && \
rm -rf /etc/systemd/system/banksyd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf composable-testnet && \
rm -rf banksy.sh && \
rm -rf .banksy && \
rm -rf $(which banksyd)
```
