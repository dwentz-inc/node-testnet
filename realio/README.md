
<p align="center">
  <img width="270" height="auto" src="https://user-images.githubusercontent.com/118625308/216108806-ef2c9a3b-023c-4539-89e2-6c4951be0c76.png">
</p>

### Spesifikasi Hardware :
NODE  | CPU     | RAM      | SSD     |
| ------------- | ------------- | ------------- | -------- |
| Testnet | 4          | 8         | 120  |


### Install otomatis
```
wget -O realio.sh https://raw.githubusercontent.com/dwentz-inc/node-testnet/main/realio/realio.sh && chmod +x realio.sh && ./realio.sh
```
### Load variable ke system
```
source $HOME/.bash_profile
```
### Snapsot

### Informasi node

* cek sync node
```
realio-networkd status 2>&1 | jq .SyncInfo
```
* cek log node
```
journalctl -fu realio-networkd -o cat
```
* cek node info
```
realio-networkd status 2>&1 | jq .NodeInfo
```
* cek validator info
```
realio-networkd status 2>&1 | jq .ValidatorInfo
```
* cek node id
```
realio-networkd tendermint show-node-id
```
### Membuat wallet
* wallet baru
```
realio-networkd keys add $WALLET
```
* recover wallet
```
realio-networkd keys add $WALLET --recover
```
* list wallet
```
realio-networkd keys list
```
* hapus wallet
```
realio-networkd keys delete $WALLET
```
### Simpan informasi wallet
```
REALIO_WALLET_ADDRESS=$(realio-networkd keys show $WALLET -a)
REALIO_VALOPER_ADDRESS=$(realio-networkd keys show $WALLET --bech val -a)
echo 'export REALIO_WALLET_ADDRESS='${REALIO_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export REALIO_VALOPER_ADDRESS='${REALIO_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Membuat validator
* cek balance
```
realio-networkd query bank balances $REALIO_WALLET_ADDRESS
```
* membuat validator
```
realio-networkd tx staking create-validator \
  --amount 1000000000000ario \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(realio-networkd tendermint show-validator) \
  --moniker $NODENAME \
  --gas=auto \
  --gas-adjustment=1.2 \
  --gas-prices=0.025ario \
  --chain-id $REALIO_CHAIN_ID
```
* edit validator
```
realio-networkd tx staking edit-validator \
  --new-moniker="nama-node" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$REALIO_CHAIN_ID \
  --gas=auto \
  --fees=260000000ario \
  --gas-adjustment=1.2 \
  --from=$WALLET
```
* unjail validator
```
realio-networkd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$REALIO_CHAIN_ID \
  --fees=200000000ario \
  --gas-adjustment=1.2 \
  --gas=auto
```
### Voting
```
realio-networkd tx gov vote 1 yes --from $WALLET --chain-id=$REALIO_CHAIN_ID --gas=auto --fees=2500000ario
```
### Delegasi dan Rewards
* delegasi
```
realio-networkd tx staking delegate $REALIO_VALOPER_ADDRESS 1000000000000ario --from=$WALLET --chain-id=$REALIO_CHAIN_ID --gas=auto --fees=250000ario
```
* withdraw reward
```
realio-networkd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$REALIO_CHAIN_ID --gas=auto --fees=2500000ario
```
* withdraw reward beserta komisi
```
realio-networkd tx distribution withdraw-rewards $REALIO_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$REALIO_CHAIN_ID --gas=auto --fees=2500000ario
```

### Hapus node
```
sudo systemctl stop realio-networkd && \
sudo systemctl disable realio-networkd && \
rm /etc/systemd/system/realio-networkd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf realio-network && \
rm -rf realio.sh && \
rm -rf .realio-network && \
rm -rf $(which realio-networkd)
```
