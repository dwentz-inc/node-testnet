
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
git clone https://github.com/playstructs/structsd
cd structsd
git checkout v0.1.0-beta
go build -o structsd cmd/structsd/main.go
mv structsd /root/go/bin
```
### Custom Port
```
PORT=23
```
```
structsd config node tcp://localhost:${PORT}657
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.structs/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.structs/config/app.toml
```
### Config node
* init node
```
structsd init yourname --chain-id structstestnet-74
```
```
structsd config chain-id structstestnet-74
structsd config keyring-backend test
```
* Download genesis and addrbook
```
wget -O $HOME/.structs/config/genesis.json "https://testnet-snapshot.genznodes.dev/structs/genesis.json"
wget -O $HOME/.structs/config/addrbook.json "https://testnet-snapshot.genznodes.dev/structs/addrbook.json"
```
* Add peers and seeds
```
PEERS=34376414f9a1755df4cdd9d97b1e86ec8d30365e@31.220.73.226:20556,7bbe533102e0312d240607dc592b04e153e43919@130.162.187.250:26656,4b91f30c824b66452b008d4e130a72ab3566e624@104.37.192.94:26656,3cc8848306c8ca8214e878aee60a9b6750f67aab@204.14.17.23:26656,bad0b99e60df4e46076665219eceb36a38fdbc0d@104.37.195.101:26656,4f1533fddf898ac488ecc8ccbd3ee692b1006ee4@204.16.202.181:26656,537bc4af86c9140b90c8b55a9a0afc4e480462f1@51.79.82.227:13656,7a946f6d235e6197bbb3da6eff32873c2201a0ff@104.37.192.93:26656,372e686bc84528d9beccf15429f94846cd0f54d8@159.69.193.68:26656,d036d13c72d470afaf217b5de0cde683dea96f9f@99.243.48.108:26656,d73ccb796f0c6f1d2be1b4f0cd75df49fdba1267@192.155.91.61:26656,880c489a51526bcc95402d82d7a379de12cfd6f2@143.47.235.98:26656,077a73c09eda5cca30e3280c588cca6188f5a8fc@94.130.220.233:23656
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" ~/.structs/config/config.toml
```
* Setup minimum Gasfee
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025alpha\"/" $HOME/.structs/config/app.toml
```
* Setup pruning
```

pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.structs/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.structs/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.structs/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.structs/config/app.toml
```
* Create service
```
sudo tee /etc/systemd/system/structsd.service > /dev/null <<EOF
[Unit]
Description=playstructs
After=network-online.target

[Service]
User=$USER
ExecStart=$(which structsd) start --home $HOME/.structs
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
sudo systemctl enable structsd
sudo systemctl restart structsd
```
```
journalctl -fu structsd -o cat
```
