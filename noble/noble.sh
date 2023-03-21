#!/bin/bash

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
NOBLE_PORT=28
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export NOBLE_CHAIN_ID=grand-1" >> $HOME/.bash_profile
echo "export NOBLE_PORT=${NOBLE_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "moniker : \e[1m\e[32m$NODENAME\e[0m"
echo -e "wallet  : \e[1m\e[32m$WALLET\e[0m"
echo -e "chain-id: \e[1m\e[32m$NOBLE_CHAIN_ID\e[0m"
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
git clone https://github.com/strangelove-ventures/noble noble
cd noble
git checkout v0.4.2
make install

# config
nobled config chain-id $NOBLE_CHAIN_ID
nobled config keyring-backend test
nobled config node tcp://localhost:${NOBLE_PORT}657

# init
nobled init $NODENAME --chain-id $NOBLE_CHAIN_ID

# download genesis and addrbook
wget -O genesis.json https://snapshots.polkachu.com/testnet-genesis/noble/genesis.json --inet4-only
mv genesis.json ~/.noble/config

# set peers and seeds
PEERS=efbc3c52ddb6433b0ad08882c77917886604dbf4@65.109.85.221:2100,0dec6766b0013a6ac6f161e7e90990395cc1e95c@135.181.200.186:26656,d1b691c7d30372b7f03af169169e8bee2159dc22@65.109.80.150:2590,4bb57f4075a485dfa3f7de6c08d1273790ff1d23@158.160.57.247:26656,d82829d886635ffcfcef66adfaa725acb522e1c6@83.136.255.243:26656,0a2f1d153753611d1e48960b1793978b0560c4bb@141.94.193.28:55776,982b9975fe24c619050d07e3aec6f25233681ba6@65.109.85.225:2100,a636699db4c2637b7b74196b7ba4919be05fa82d@35.190.132.155:26656,5298a3f0e1073f60b366cd98888c9f6d0c115eee@154.38.166.81:26656,047173cca5b39aa7c9cd63a141cf6fcd7d37bc3b@89.58.13.11:26656,e1a9c14aed7d9fa48444b38fef462619b7cb0f6d@65.109.85.226:2100,57546d799a1cdef74b9a174052821a6e93636dfc@34.145.87.4:26656,bed2a40cfc5394a65aaecbdeaf3bd35488a6ef82@43.157.55.4:26656,7a4eb59a4eba959ed1203f9b002eaaffc2174009@211.219.19.69:26656,1c6b3f4902bc0d3bd0420cceddc6f91c22c9273d@43.157.15.16:26656,63e95eee5e07ba055cdaa00d8ab4f0c8f9339f10@3.76.85.22:26686,38179b18853d6a8cb86b99881e02cf72f18b9d0f@34.105.68.123:26656,f4c82dee72187332df925eac4dc3b3fcdcc1765f@65.109.28.219:21556,20b4f9207cdc9d0310399f848f057621f7251846@222.106.187.13:42800,6b76ad22a73897e3c39c7d87b7d12a3b7d690bff@34.83.170.218:26656,3e842b65e55c3aeecc87182e1c253fe6c5bdf7a6@78.46.99.50:23656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.noble/config/config.toml


# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NOBLE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NOBLE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NOBLE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NOBLE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NOBLE_PORT}660\"%" $HOME/.noble/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NOBLE_PORT}317\"%; s%^address = \":8080\"%address = \":${NOBLE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NOBLE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NOBLE_PORT}091\"%" $HOME/.noble/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.noble/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.noble/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.noble/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.noble/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025uusdc\"/" $HOME/.noble/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.noble/config/config.toml

# reset
nobled tendermint unsafe-reset-all --home $HOME/.noble

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/nobled.service > /dev/null <<EOF
[Unit]
Description=noble
After=network-online.target

[Service]
User=$USER
ExecStart=$(which nobled) start --home $HOME/.noble
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable nobled
sudo systemctl restart nobled

echo '=============== SETUP FINISHED ==================='
