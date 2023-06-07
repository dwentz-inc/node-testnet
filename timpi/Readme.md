### Install prequirement
```
sudo apt update && sudo apt upgrade -y
```
```
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

### Install go
```
ver="1.20.4"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```
### Download binary
```
git clone https://github.com/Timpi-official/Timpi-ChainTN.git
cd Timpi-ChainTN
cd cmd/TimpiChain
go build
cp TimpiChain /root/go/bin/timpid
```

### Config Node
* Init Node
```
timpid init CHANGEWITHYOURNAMEMONIKER --chain-id TimpiChainTN
```

```
timpid config chain-id TimpiChainTN
timpid config keyring-backend test
```
* Download Genesis
```
wget -O genesis.json https://ss.nodeist.net/t/timpi/genesis.json --inet4-only
mv genesis.json ~/.TimpiChain/config

```
* Add Peers or Seed
```
PEERS=dfb017436f9d4898ffbacd26f9965bd1e273351b@148.113.138.171:26656,7d6938bdfce943c1d2ba10f3c3f0fe8be7ba7b2c@173.249.54.208:26656,319ec1fd84c147d49f08078aef085c57a8edf09a@45.79.48.248:26656,0373e97105a51c2711ba486f8906acb8da1978f7@167.235.153.124:26656,1a99c42921864c8dc322a579bd57ce2f4778a9f1@5.180.186.25:26656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.TimpiChain/config/config.toml
```
* Setup minimum GasFee
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025utimpiTN\"/" $HOME/.TimpiChain/config/app.toml
```
* Setup pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.TimpiChain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.TimpiChain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.TimpiChain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.TimpiChain/config/app.toml
```
* Create service
```
sudo tee /etc/systemd/system/timpid.service > /dev/null <<EOF
[Unit]
Description=timpi
After=network-online.target

[Service]
User=$USER
ExecStart=$(which timpid) start --home $HOME/.TimpiChain
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### Launch Node
```
sudo systemctl daemon-reload 
sudo systemctl enable timpid
sudo systemctl restart timpid
```
```
journalctl -fu timpid -o cat
```
