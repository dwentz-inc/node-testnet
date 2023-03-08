#!/bin/bash

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
OJO_PORT=32
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export OJO_CHAIN_ID=ojo-devnet" >> $HOME/.bash_profile
echo "export OJO_PORT=${OJO_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "moniker : \e[1m\e[32m$NODENAME\e[0m"
echo -e "wallet  : \e[1m\e[32m$WALLET\e[0m"
echo -e "chain-id: \e[1m\e[32m$OJO_CHAIN_ID\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt list --upgradable && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
ver="1.19.5" && \
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
rm -rf ojo
git clone https://github.com/ojo-network/ojo.git
cd ojo
git checkout v0.1.2
make install

# config
ojod config chain-id $OJO_CHAIN_ID
ojod config keyring-backend test
ojod config node tcp://localhost:${OJO_PORT}657

# init
ojod init $NODENAME --chain-id $OJO_CHAIN_ID

# download genesis and addrbook
wget -O genesis.json https://snapshots.nodeist.net/t/ojo/genesis.json --inet4-only
mv genesis.json ~/.ojo/config

# set peers and seeds
PEERS=5af3d50dcc231884f3d3da3e3caecb0deef1dc5b@142.132.134.112:25356,c0ee71c74858b339787320596b805ed631c48ebb@213.133.100.172:27433,affee2f485ca15c68c302ad98e8de41fcd0e71ba@162.19.238.49:26656,fbeb2b37fe139399d7513219e25afd9eb8f81f4f@65.21.170.3:38656,dc19e5d986ea79e70180cfbee7789de9cd79e14e@95.217.57.232:56656,97ff540b57b89dd0b6737eddb92977523dd5a7b3@195.3.221.58:12656,8a8b9a8a58c922a7693715100710697ec69b1478@65.109.92.235:11086,7416a65de3cc548a537dbb8bdf93dbd83fe401d2@78.107.234.44:26656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.ojo/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${OJO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${OJO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${OJO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${OJO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${OJO_PORT}660\"%" $HOME/.ojo/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${OJO_PORT}317\"%; s%^address = \":8080\"%address = \":${OJO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${OJO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${OJO_PORT}091\"%" $HOME/.ojo/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.ojo/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.ojo/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.ojo/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.ojo/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.00uojo\"/" $HOME/.ojo/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.ojo/config/config.toml

# reset
ojod tendermint unsafe-reset-all --home $HOME/.ojo

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/ojod.service > /dev/null <<EOF
[Unit]
Description=ojo
After=network-online.target

[Service]
User=$USER
ExecStart=$(which ojod) start --home $HOME/.ojo
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable ojod
sudo systemctl restart ojod

echo '=============== SETUP FINISHED ==================='
