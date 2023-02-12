#!/bin/bash

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
REALIO_PORT=28
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export REALIO_CHAIN_ID=realionetwork_1110-2" >> $HOME/.bash_profile
echo "export REALIO_PORT=${REALIO_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "moniker : \e[1m\e[32m$NODENAME\e[0m"
echo -e "wallet  : \e[1m\e[32m$WALLET\e[0m"
echo -e "chain-id: \e[1m\e[32m$REALIO_CHAIN_ID\e[0m"
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
cd $HOME
git clone https://github.com/realiotech/realio-network.git
cd realio-network
git checkout v0.7.2
make install


# config
realio-networkd config chain-id $REALIO_CHAIN_ID
realio-networkd config keyring-backend test
realio-networkd config node tcp://localhost:${REALIO_PORT}657

# init
realio-networkd init $NODENAME --chain-id $REALIO_CHAIN_ID

# download genesis and addrbook
wget -O genesis.json "https://raw.githubusercontent.com/realiotech/testnets/main/realionetwork_1110-2/genesis.json"
mv genesis.json ~/.realio-network/config

# set peers and seeds
PEERS="1057d9a2d9231093b4aadf3015efff8293290859@realio-testnet-peer.itrocket.net:443,bef3c95566f02c82603e5911540f7249cacd1867@p2p-realio.genznodes.dev:26656,3c2eda73a5a7ba73b3f9cc6f2a1452e58c765dbd@95.216.14.72:23656,397a0703715667b555086d663eccc1f13939c63c@realio.peer.stavr.tech:21096,6db56c79ee7438876d76550aa24c5acb51104306@65.109.104.118:61156,672c28ea5435aeffe5ae057774f9175a740ab4f2@178.63.102.172:37656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.realio-network/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${REALIO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${REALIO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${REALIO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${REALIO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${REALIO_PORT}660\"%" $HOME/.realio-network/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${REALIO_PORT}317\"%; s%^address = \":8080\"%address = \":${REALIO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${REALIO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${REALIO_PORT}091\"%" $HOME/.realio-network/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.realio-network/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.realio-network/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.realio-network/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.realio-network/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025ario\"/" $HOME/.realio-network/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.realio-network/config/config.toml

# reset
realio-networkd tendermint unsafe-reset-all --home $HOME/.realio-network

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/realio-networkd.service > /dev/null <<EOF
[Unit]
Description=realio-network
After=network-online.target

[Service]
User=$USER
ExecStart=$(which realio-networkd) start --home $HOME/.realio-network
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable realio-networkd
sudo systemctl restart realio-networkd

echo '=============== SETUP FINISHED ==================='
