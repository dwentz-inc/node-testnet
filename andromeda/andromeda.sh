#!/bin/bash

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
ANDROMEDA_PORT=28
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export ANDROMEDA_CHAIN_ID=galileo-3" >> $HOME/.bash_profile
echo "export ANDROMEDA_PORT=${ANDROMEDA_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "moniker : \e[1m\e[32m$NODENAME\e[0m"
echo -e "wallet  : \e[1m\e[32m$WALLET\e[0m"
echo -e "chain-id: \e[1m\e[32m$ANDROMEDA_CHAIN_ID\e[0m"
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
git clone https://github.com/andromedaprotocol/andromedad
cd andromedad
git checkout Galileo-3v1.0.0-beta1
make install

# config
andromedad config chain-id $ANDROMEDA_CHAIN_ID
andromedad config keyring-backend test
andromedad config node tcp://localhost:${ANDROMEDA_PORT}657

# init
andromedad init $NODENAME --chain-id $ANDROMEDA_CHAIN_ID

# download genesis and addrbook
wget -O genesis.json "https://raw.githubusercontent.com/andromedaprotocol/testnets/galileo-3/genesis.json"
mv genesis.json ~/.andromedad/config

# set peers and seeds
PEERS=""
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.andromedad/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${ANDROMEDA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${ANDROMEDA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${ANDROMEDA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${ANDROMEDA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${ANDROMEDA_PORT}660\"%" $HOME/.andromedad/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${ANDROMEDA_PORT}317\"%; s%^address = \":8080\"%address = \":${ANDROMEDA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${ANDROMEDA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${ANDROMEDA_PORT}091\"%" $HOME/.andromedad/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.andromedad/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025uandr\"/" $HOME/.andromedad/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.andromedad/config/config.toml

# reset
andromedad tendermint unsafe-reset-all --home $HOME/.andromedad

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/andromedad.service > /dev/null <<EOF
[Unit]
Description=andromeda
After=network-online.target

[Service]
User=$USER
ExecStart=$(which andromedad) start --home $HOME/.andromedad
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable andromedad
sudo systemctl restart andromedad

echo '=============== SETUP FINISHED ==================='
