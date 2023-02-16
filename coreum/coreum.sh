#!/bin/bash

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
COREUM_PORT=29
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export COREUM_CHAIN_ID=coreum-testnet-1" >> $HOME/.bash_profile
echo "export COREUM_PORT=${COREUM_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "moniker : \e[1m\e[32m$NODENAME\e[0m"
echo -e "wallet  : \e[1m\e[32m$WALLET\e[0m"
echo -e "chain-id: \e[1m\e[32m$COREUM_CHAIN_ID\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt list --upgradable && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
ver="1.19" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
git clone https://github.com/CoreumFoundation/coreum/
cd coreum
git checkout v0.1.1
go build -o cored cmd/cored/main.go

# config
cored config chain-id $COREUM_CHAIN_ID
cored config keyring-backend test
cored config node tcp://localhost:${COREUM_PORT}657

# init
cored init $NODENAME --chain-id $COREUM_CHAIN_ID

# download genesis
wget -O genesis.json "https://snap.nodexcapital.com/coreum/genesis.json"
mv genesis.json ~/.core/config

# download addrbook
wget -O addrbook.json https://snap.nodexcapital.com/coreum/addrbook.json
mv addrbook.json ~/.core/config

# set peers and seeds
PEERS="69d7028b7b3c40f64ea43208ecdd43e88c797fd6@34.69.126.231:26656,b2978432c0126f28a6be7d62892f8ded1e48d227@34.70.241.13:26656,7c0d4ce5ad561c3453e2e837d85c9745b76f7972@35.238.77.191:26656,0aa5fa2507ada8a555d156920c0b09f0d633b0f9@34.173.227.148:26656,4b8d541efbb343effa1b5079de0b17d2566ac0fd@34.172.70.24:26656,27450dc5adcebc84ccd831b42fcd73cb69970881@35.239.146.40:26656,5add70ec357311d07d10a730b4ec25107399e83c@5.196.7.58:26656,1a3a573c53a4b90ab04eb47d160f4d3d6aa58000@35.233.117.165:26656,abbeb588ad88176a8d7592cd8706ebbf7ef20cfe@185.241.151.197:26656,39a34cd4f1e908a88a726b2444c6a407f67e4229@158.160.59.199:26656,051a07f1018cfdd6c24bebb3094179a6ceda2482@138.201.123.234:26656,cc6d4220633104885b89e2e0545e04b8162d69b5@75.119.134.20:26656"
SEEDS="64391878009b8804d90fda13805e45041f492155@35.232.157.206:26656,53f2367d8f8291af8e3b6ca60efded0675ff6314@34.29.15.170:26656"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/.core/config/config.toml
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.core/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${COREUM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${COREUM_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${COREUM_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${COREUM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${COREUM_PORT}660\"%" $HOME/.core/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${COREUM_PORT}317\"%; s%^address = \":8080\"%address = \":${COREUM_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${COREUM_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${COREUM_PORT}091\"%" $HOME/.core/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.core/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.core/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.core/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.core/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025uandr\"/" $HOME/.cored/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.core/config/config.toml

# reset
cored tendermint unsafe-reset-all --home $HOME/.core

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/cored.service > /dev/null <<EOF
[Unit]
Description=coreum
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cored) start --home $HOME/.core
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable cored
sudo systemctl restart cored

echo '=============== SETUP FINISHED ==================='
