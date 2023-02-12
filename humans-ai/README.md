<p align="center">
  <img width="240" height="auto" src="https://user-images.githubusercontent.com/108969749/207439055-71e669e0-1ad0-4920-991a-739f908992cb.jpeg">
</p>

### Spesifikasi Hardware :
NODE  | CPU     | RAM      | SSD     |
| ------------- | ------------- | ------------- | -------- |
| Testnet | 4          | 8         | 256  |


### Install otomatis
```
wget -O humans.sh https://raw.githubusercontent.com/dwentz-inc/node-testnet/main/humans-ai/humans.sh && chmod +x humans.sh && ./humans.sh
```
### Load variable ke system
```
source $HOME/.bash_profile
```
### Snapshot by #BCCNodes
```

systemctl stop humansd.service

cp $HOME/.humans/data/priv_validator_state.json $HOME/.humans/priv_validator_state.json.backup

rm -rf ~/.humans/data; \
mkdir -p ~/.humans/data; \
cd ~/.humans/data


SNAP_NAME=$(curl -s https://snapshots.bccnodes.com/testnets/humans/ | egrep -o ">testnet-1.*tar" | tail -n 1 | tr -d '>'); \
wget -O - https://snapshots.bccnodes.com/testnets/humans/${SNAP_NAME} | tar xf -

mv $HOME/.humans/priv_validator_state.json.backup $HOME/.humans/data/priv_validator_state.json


wget -O $HOME/.humans/config/addrbook.json "https://raw.githubusercontent.com/BccNodes/Snapshot-Statesync/main/Humans%20Testnet-1/addrbook.json"


systemctl start humansd.service; \
journalctl -u humansd.service -f --no-hostname

```

### Informasi node

* cek sync node
```
humansd status 2>&1 | jq .SyncInfo
```
* cek log node
```
journalctl -fu humansd -o cat
```
* cek node info
```
humansd status 2>&1 | jq .NodeInfo
```
* cek validator info
```
humansd status 2>&1 | jq .ValidatorInfo
```
* cek node id
```
humansd tendermint show-node-id
```
### Membuat wallet
* wallet baru
```
humansd keys add $WALLET
```
* recover wallet
```
humansd keys add $WALLET --recover
```
* list wallet
```
humansd keys list
```
* hapus wallet
```
humansd keys delete $WALLET
```
### Simpan informasi wallet
```
HUMAN_WALLET_ADDRESS=$(humansd keys show $WALLET -a)
HUMAN_VALOPER_ADDRESS=$(humansd keys show $WALLET --bech val -a)
echo 'export HUMAN_WALLET_ADDRESS='${HUMAN_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export HUMAN_VALOPER_ADDRESS='${HUMAN_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Membuat validator
* cek balance
```
humansd query bank balances $HUMAN_WALLET_ADDRESS
```
* membuat validator
```
humansd tx staking create-validator \
  --amount 1000000uheart \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(humansd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $HUMAN_CHAIN_ID
```
* edit validator
```
humansd tx staking edit-validator \
  --new-moniker="nama-node" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$HUMAN_CHAIN_ID \
  --from=$WALLET
```
* unjail validator
```
humansd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$HUMAN_CHAIN_ID \
  --gas=auto
```
### Voting
```
humansd tx gov vote 1 yes --from $WALLET --chain-id=$HUMAN_CHAIN_ID --gas=auto --fees=250uheart
```
### Delegasi dan Rewards
* delegasi
```
humansd tx staking delegate $HUMAN_VALOPER_ADDRESS 1000000uheart --from=$WALLET --chain-id=$HUMAN_CHAIN_ID --gas=auto --fees=250uheart
```
* withdraw reward
```
humansd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$HUMAN_CHAIN_ID --gas=auto --fees=250uheart
```
* withdraw reward beserta komisi
```
humansd tx distribution withdraw-rewards $HUMAN_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$HUMAN_CHAIN_ID --gas=auto --fees=250uheart
```

### Hapus node
```
sudo systemctl stop humansd && \
sudo systemctl disable humansd && \
rm /etc/systemd/system/humansd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf humans && \
rm -rf humans.sh && \
rm -rf .humans && \
rm -rf $(which humansd)
```
