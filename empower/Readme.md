### Install prequirement
```
sudo apt update && sudo apt upgrade -y
```
```
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

### Install go
```
ver="1.20.2"
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
cd $HOME
git clone https://github.com/EmpowerPlastic/empowerchain
cd empowerchain/chain
git checkout v1.0.0-rc1
make build
```

### Config Node
* Init Node
```
empowerd init CHANGEWITHYOURNAMEMONIKER --chain-id circulus-1
```

```
empowerd config chain-id circulus-1
empowerd config keyring-backend test
```
* Download Genesis
```
curl -Ls https://snapshots.indonode.net/empower-t/genesis.json > $HOME/.empowerchain/config/genesis.json

```
* Add Peers or Seed
```
SEEDS="258f523c96efde50d5fe0a9faeea8a3e83be22ca@seed.circulus-1.empower.aviaone.com:20272,d6a7cd9fa2bafc0087cb606de1d6d71216695c25@51.159.161.174:26656,babc3f3f7804933265ec9c40ad94f4da8e9e0017@testnet-seed.rhinostake.com:17456"
PEERS=""
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.empowerchain/config/config.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\" /" $HOME/.empowerchain/config/config.toml

```

* Setup minimum GasFee
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025umpwr\"/" $HOME/.empowerchain/config/app.toml
```
* Setup pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.empowerchain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.empowerchain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.empowerchain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.empowerchain/config/app.toml
```
* Create service
```
sudo tee /etc/systemd/system/empowerd.service > /dev/null <<EOF
[Unit]
Description=timpi
After=network-online.target

[Service]
User=$USER
ExecStart=$(which empowerd) start --home $HOME/.empowerchain
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
sudo systemctl enable empowerd
sudo systemctl restart empowerd
```
```
journalctl -fu empowerd -o cat
```
