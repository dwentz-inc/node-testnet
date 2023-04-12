#!/bin/bash

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
SGE_PORT=25
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export SGE_CHAIN_ID=sge-testnet-1" >> $HOME/.bash_profile
echo "export SGE_PORT=${SGE_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "moniker : \e[1m\e[32m$NODENAME\e[0m"
echo -e "wallet  : \e[1m\e[32m$WALLET\e[0m"
echo -e "chain-id: \e[1m\e[32m$SGE_CHAIN_ID\e[0m"
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
git clone https://github.com/sge-network/sge.git
cd sge
git checkout v0.0.3
go mod tidy
make install


# config
sged config chain-id $SGE_CHAIN_ID
sged config keyring-backend test
sged config node tcp://localhost:${SGE_PORT}657

# init
sged init $NODENAME --chain-id $SGE_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.sge/config/genesis.json "https://raw.githubusercontent.com/sge-network/networks/master/sge-testnet-1/genesis.json"

# set peers and seeds
PEERS=971643c5b9f9d279cfb7ac1b14accd109231236b@65.108.15.170:26656,1168931936c638e92ea6d93e2271b3fe5faee6d1@51.91.145.100:26656,4a3f59e30cde63d00aed8c3d15bef46b34ec2c7f@50.19.180.153:26656,27f0b281ea7f4c3db01fdb9f4cf7cc910ad240a6@209.34.206.44:26656,a05353fe9ae39dd0edbfa6341634dec781d84a5c@65.108.105.48:17756,788bb7ee73c023f70c41360e9014544b12fe23f9@3.15.209.96:26656,aa7da79247bc7f66993adc5bced6396466390ce7@52.22.148.61:26656,12450c4223a2d6dcfbe5e9b9998cb67634cd2465@38.146.3.193:26656,43b05a6bab7ca735397e9fae2cb0ad99977cf482@34.82.157.5:26656,413128504de36317e3bf000073aa3165351e0d52@44.197.179.40:26656,07fc54214e4f162d5d94607c83d2d6e0b256f161@52.44.14.245:26656,a6976d1348baf92d839edc11cd7a7476a120909b@18.207.110.2:26656,08ba236f6392c80dd865d2fd84250cb6f016ab0b@35.174.81.173:26656,f01f3f8dd37d5c601145e4c021e90245ddb63d93@65.108.2.41:56656,d79b994f1a31a59af7fcf89bba512d0c9afdc06d@94.130.219.37:26000,95fb63fbf8ac2647fc4e6c9f73fd6db736bb28ed@52.55.235.60:26656,445506c736895336e36dd4f8228a60c257b30e61@20.12.75.0:26656,80973dcc0deb52ae96f80b9f147c3f601bea63fb@135.125.180.36:20656,2299d372bd2067b9fe05aacf94b3f2a5ad0f1b3b@212.8.240.13:2516,7bd0d8c9a0cbfca490a8724a40252d01745c4f61@3.235.5.252:26656,83765779af680d6dc2dd523c2f95ce541ed6a6e8@155.133.22.10:43956,e1ff129fd59ce16f9f9762c76235a45293b0b6a5@18.223.184.59:26656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.sge/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${SGE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${SGE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${SGE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${SGE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${SGE_PORT}660\"%" $HOME/.sge/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${SGE_PORT}317\"%; s%^address = \":8080\"%address = \":${SGE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${SGE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${SGE_PORT}091\"%" $HOME/.sge/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sge/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.sge/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.sge/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.sge/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.000025usge\"/" $HOME/.sge/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.sge/config/config.toml

# reset
sged tendermint unsafe-reset-all --home $HOME/.sge

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/sged.service > /dev/null <<EOF
[Unit]
Description=sge
After=network-online.target

[Service]
User=$USER
ExecStart=$(which sged) start --home $HOME/.sge
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable sged
sudo systemctl restart sged

echo '=============== SETUP FINISHED ==================='
