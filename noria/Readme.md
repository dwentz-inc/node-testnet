### install package
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```
### install go
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
### install binary
```
git clone https://github.com/noria-net/noria.git
cd noria
git checkout v1.3.0
make install
```
### config init node
```
MONIKER=
CHAIN-ID=oasis-3
```
```
noriad init $MONIKER --chain-id $CHAIN-ID
noriad config chain-id $CHAIN-ID
noriad config keyring-backend test
```
### custom port
```
PORT=xx
noriad config node tcp://localhost:${PORT}657
```
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/.noria/config/config.toml
sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"localhost:9090\"%address = \"localhost:${PORT}090\"%; s%^address = \"localhost:9091\"%address = \"localhost:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${PORT}546\"%" $HOME/.noria/config/app.toml
```
### download genesis
```
wget https://raw.githubusercontent.com/noria-net/noria/main/genesis.json -O $HOME/.noria/config/genesis.json
```
### seed peers
```
SEEDS=""
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/.noria/config/config.toml
peers="e82fb793620a13e989be8b2521e94db988851c3c@165.227.113.152:26656,adb152a90a61b910feb4b2cdbd3f897251aa5452@116.202.227.117:16156,ad749d0e0c6542b89b5f98dfafe05cb527d0b9fc@65.109.6.138:26656,f60568a6ed1f848857c1c6c113719c1bb687c656@65.108.105.48:22156,60a15b1b7feb62b65d58cb4721340907c2092099@65.108.6.45:61656,5eedd8cf7fefc037a6233b1991c2a3b653518560@65.108.230.113:31066,419438c7cb152a88a30d6922a2b2c7077dd4daf5@88.99.3.158:22156,73e5dc6e04a1dd28e5851191eb9dede07f0b38fb@141.94.99.87:14095,4d8147a80c46ba21a8a276d55e6993353e03a734@165.22.42.220:26656,5c2a752c9b1952dbed075c56c600c3a79b58c395@185.16.39.172:27316,6b00a46b8c79deab378a8c1d5c2a63123b799e46@34.69.0.43:26656,31df60c419e4e5ab122ca17d95419a654729cbb7@102.130.121.211:26656,846731f7097e684efdd6b9446d562228640e2b14@34.27.228.66:26656,bb04cbb3b917efce76a8296a8411f211bad14352@159.203.5.100:26656,38de00b6d88286553eb123d16846190e5c594c59@51.79.30.118:26656,d80daf11b1b336027bb3f50dc67b9c8f6be153b0@195.201.195.61:29656,0fbeb25dfdae849be87d96a32050741a77983b13@34.87.180.66:26656,8336e98410c1c9b91ef86f13a3254a2b30a1a263@65.108.226.183:22156,42798554b12ff3c24107af3b47a28459d717bdf4@46.17.250.108:61356"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.noria/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.0025ucrd\"|" $HOME/.noria/config/app.toml
```
### pruning
```
sed -i \
-e 's|^pruning *=.*|pruning = "custom"|' \
-e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
-e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
-e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
$HOME/.noria/config/app.toml
```
### create service
```
sudo tee /etc/systemd/system/noriad.service > /dev/null <<EOF
[Unit]
Description=noria
After=network-online.target

[Service]
User=$USER
ExecStart=$(which noriad) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### start node
```
sudo systemctl daemon-reload && sudo systemctl enable noriad
```
```
systemctl restart noriad && journalctl -fu noriad -o cat
```
