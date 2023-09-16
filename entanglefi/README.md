
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
git clone https://github.com/Entangle-Protocol/entangle-blockchain
cd entangle-blockchain
```
```
make install
```

### Config Node
* Init Node
```
entangled init dwentz --chain-id entangle_33133-1
```
```
entangledd config chain-id entangle_33133-1
entangledd config keyring-backend test
```
* Download Genesis
```
curl -Ls https://raw.githubusercontent.com/Entangle-Protocol/entangle-blockchain/main/config/genesis.json > $HOME/.entangled/config/genesis.json


```
* Custom port
```
PORT=20
```
```
entangled config node tcp://localhost:${PORT}657
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.entangled/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.entangled/config/app.toml


```
* Add Peers or Seed
```
sed -i -e "s|^seeds *=.*|seeds = \"76492a1356c14304bdd7ec946a6df0b57ba51fe2@3.92.0.61:26656\"|" $HOME/.entangled/config/config.toml
PEERS="e41f250264b5c2aa14933a344c17a1be924b42c0@3.94.197.61:26656,12df82148348b61f5faf2f2e0373863a66114ebb@54.198.127.212:26656,c371d9b07cf615ea72ffab1de2b9549b1b7b937c@34.227.9.141:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.entangled/config/config.toml

```
* Setup minimum GasFee
```

```

* Setup pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.entangled/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.entangled/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.entangled/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.entangled/config/app.toml
```
* Create service
```
sudo tee /etc/systemd/system/entangled.service > /dev/null <<EOF
[Unit]
Description=entangle
After=network-online.target

[Service]
User=$USER
ExecStart=$(which entangled) start --home $HOME/.entangled
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### Launch Node
```
sudo systemctl enable entangled
```
```
sudo systemctl restart entangled
```
### Check log node
```
journalctl -fu entangled -o cat
```
