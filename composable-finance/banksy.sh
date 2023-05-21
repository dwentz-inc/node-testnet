#!/bin/bash

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
BANKSY_PORT=28
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export BANKSY_CHAIN_ID=banksy-testnet-2" >> $HOME/.bash_profile
echo "export BANKSY_PORT=${BANKSY_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "moniker : \e[1m\e[32m$NODENAME\e[0m"
echo -e "wallet  : \e[1m\e[32m$WALLET\e[0m"
echo -e "chain-id: \e[1m\e[32m$BANKSY_CHAIN_ID\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt list --upgradable && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
ver="1.20.2" && \
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
git clone https://github.com/notional-labs/composable-testnet
cd composable-testnet
git checkout v2.3.3-testnet2fork
make install

# config
banksyd config chain-id $BANKSY_CHAIN_ID
banksyd config keyring-backend test
banksyd config node tcp://localhost:${BANKSY_PORT}657

# init
banksyd init $NODENAME --chain-id $BANKSY_CHAIN_ID

# download genesis and addrbook
wget -O ~/.banksy/config/genesis.json https://raw.githubusercontent.com/notional-labs/composable-networks/main/testnet-2/pregenesis.json

# set custom ports
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:15958\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:15957\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:15960\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:15956\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":15966\"%" $HOME/.banksy/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:15917\"%; s%^address = \":8080\"%address = \":15980\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:15990\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:15991\"%; s%:8545%:15945%; s%:8546%:15946%; s%:6065%:15965%" $HOME/.banksy/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.banksy/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.banksy/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.banksy/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.banksy/config/app.toml

# set minimum gas price and timeout commit
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0upica\"/;" ~/.banksy/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.banksy/config/config.toml
external_address=$(wget -qO- eth0.me) 
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.banksy/config/config.toml
peers="7a4247261bad16289428543538d8e7b0c785b42c@135.181.22.94:26656,1d1b341ee37434cbcf23231d89fa410aeb970341@65.108.206.74:36656,73190b1ec85654eeb7ccdc42538a2bb4a98b2802@194.163.165.176:46656,837d9bf9a4ce4d8fd0e7b0cbe51870a2fa29526a@65.109.85.170:58656,085e6b4cf1f1d6f7e2c0b9d06d476d070cbd7929@banksy.sergo.dev:11813,d9b5a5910c1cf6b52f79aae4cf97dd83086dfc25@65.108.229.93:27656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.banksy/config/config.toml
seeds="3f472746f46493309650e5a033076689996c8881@composable-testnet.rpc.kjnodes.com:15959"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.banksy/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $HOME/.banksy/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $HOME/.banksy/config/config.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.banksy/config/config.toml

# reset
banksyd tendermint unsafe-reset-all --home $HOME/.banksy

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
tee /etc/systemd/system/banksyd.service > /dev/null <<EOF
[Unit]
Description=banksyd
After=network-online.target

[Service]
User=$USER
ExecStart=$(which banksyd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable banksyd
sudo systemctl restart banksyd

echo '=============== SETUP FINISHED ==================='
