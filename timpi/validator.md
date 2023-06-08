### Informasi node
* cek sync node
```
timpid status 2>&1 | jq .SyncInfo
```
* cek log node
```
journalctl -fu timpid -o cat
```
* cek node info
```
timpid status 2>&1 | jq .NodeInfo
```
* cek validator info
```
timpid status 2>&1 | jq .ValidatorInfo
```
* cek node id
```
timpid tendermint show-node-id
```
### Membuat wallet
* wallet baru
```
timpid keys add $WALLET
```
* recover wallet
```
timpid keys add $WALLET --recover
```
* list wallet
```
timpid keys list
```
* hapus wallet
```
timpid keys delete $WALLET
```
### simpan informasi wallet ke node
```
TIMPI_WALLET_ADDRESS=$(timpid keys show $WALLET -a)
TIMPI_VALOPER_ADDRESS=$(timpid keys show $WALLET --bech val -a)
echo 'export TIMPI_WALLET_ADDRESS='${TIMPI_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export TIMPI_VALOPER_ADDRESS='${TIMPI_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### membuat validator
* cek balance 
```
timpid query bank balances $TIMPI_WALLET_ADDRESS
```
* create validator
```
timpid tx staking create-validator \
  --amount 2900000utimpiTN \
  --from $WALLET \
  --commission-max-change-rate "0.02" \
  --commission-max-rate "0.2" \
  --identity "F57A71944DDA8C4B" \
  --website https://dwentz.xyz \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(timpid tendermint show-validator) \
  --moniker Dwentz \
  --gas=auto \
  --gas-adjustment=1.2 \
  --gas-prices=0.025utimpiTN \
  --chain-id TimpiChainTN
  ```
  * edit validator
  ```
  timpid tx staking edit-validator \
  --new-moniker="nama-node" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=TimpiChainTN \
  --gas=auto \
  --fees=260000000utimpiTN \
  --gas-adjustment=1.2 \
  --from=$WALLET
  ```
  * unjail validator
  ```
  timpid tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=TimpiChainTN \
  --fees=20000utimpiTN \
  --gas-adjustment=1.4 \
  --gas=auto
  ```
  * voting
  ```
  timpid tx gov vote 1 yes --from $WALLET --chain-id=TimpiChainTN --gas=auto --fees=2500000utimpiTN
  ```
  ### Delegasi dan Rewards
* delegasi
```
timpid tx staking delegate $TIMPI_VALOPER_ADDRESS 10000000utimpiTN --from=$WALLET --chain-id=TimpiChainTN --gas=auto --fees=2500utimpiTN

```
* withdraw reward
```
timpid tx distribution withdraw-all-rewards --from=$WALLET --chain-id=TimpiChainTN --gas=auto --fees=2500000utimpiTN
```
* withdraw reward beserta komisi
```
timpid tx distribution withdraw-rewards $TIMPI_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=TimpiChainTN --gas=auto --fees=25000utimpiTN
```
### Hapus node
```
sudo systemctl stop  timpid && \
sudo systemctl disable  timpid && \
rm -rf /etc/systemd/system/timpid.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf Timpi-ChainTN && \
rm -rf .TimpiChain && \
rm -rf $(which timpid)
```
