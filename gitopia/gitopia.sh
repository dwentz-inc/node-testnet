#!/bin/bash

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
GITOPIA_PORT=27
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export GITOPIA_CHAIN_ID=gitopia-janus-testnet-2" >> $HOME/.bash_profile
echo "export GITOPIA_PORT=${GITOPIA_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "moniker : \e[1m\e[32m$NODENAME\e[0m"
echo -e "wallet  : \e[1m\e[32m$WALLET\e[0m"
echo -e "chain-id: \e[1m\e[32m$GITOPIA_CHAIN_ID\e[0m"
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
curl https://get.gitopia.com | bash
git clone -b v1.2.0 gitopia://gitopia/gitopia
cd gitopia && make install

# config
gitopiad config chain-id $GITOPIA_CHAIN_ID
gitopiad config keyring-backend test
gitopiad config node tcp://localhost:${GITOPIA_PORT}657

# init
gitopiad init $NODENAME --chain-id $GITOPIA_CHAIN_ID

# download genesis and addrbook
wget https://server.gitopia.com/raw/gitopia/testnets/master/gitopia-janus-testnet-2/genesis.json.gz
gunzip genesis.json.gz
mv genesis.json $HOME/.gitopia/config/genesis.json

# set peers and seeds
PEERS=2330fa28b8613786c741778d057616e3b91a8ae9@185.197.195.242:46656,f0a82f850a0da74c32836b125a52bdfd9a78fdd7@65.108.105.48:11356,ce4d9462b4bb348f1a006faabb40fc4271476463@38.146.3.230:11356,73de34b1d08fdd58b5a5c0ec6d2560310c1ebe90@38.242.151.86:26656,e704537ce1348bfc7b781d6546ae272ff3eea8d5@34.117.96.202:26656,82b9863205e54e67d0f9d1e93c4ae127e732810c@34.142.232.42:26656,db5f2aeda7308f395b7e32a65aec7b8b23a6817f@95.216.161.242:19656,63381c5528ed8ca93f9ba31008a9630d21b29a97@142.132.152.46:46656,feb1e78c3e598da65c613aead4b6112c08efc710@34.143.188.67:26656,6d36c85a0fc1d737906f47af2e090734e0f6d4a3@86.48.3.99:26656,b4c4b59cdf919d62ae4cec688f6fb7883ac73f86@65.108.66.34:29686,399d4e19186577b04c23296c4f7ecc53e61080cb@34.126.153.85:26656,0f02c58c7f44d61e51485e175ed8f169d6127716@34.143.226.108:26656,a2f5b00e64395b6eb274724b7fcc1c442ead84d7@34.143.201.1:26656,b5a31780f568a1959cd28ec12f642ce9a8132c97@138.201.187.5:26656,f3f72cf59352deed9a59eecef4884e12710c2177@65.109.85.225:7040,098c8f3e70fa1f1bbb447903aea96b8e1f025f13@65.109.50.106:656,f4aa89dc3ce87be9afba43ec16fb9e6ee7e979b0@65.109.85.221:7040,0ec4f51338097f7f7973b2ab7fd750ec83358307@65.109.85.226:7040,1989ced6b71ce676a5ab4d0586d85e38fd41fbd2@136.243.88.91:7070,798cf016b5150592badc8257402312fc50b7361d@65.108.45.200:26878,df5b61e51ab2f6c3bf1f3c387ba1586a84b41b25@141.95.65.26:27956,2853f7582257f0a19854072906e21eb694aa05b4@80.79.6.253:26656,4fcd7fd0a9585f3ddc547ec7204b2bbafa35f2f2@185.92.148.124:36656,edbcfa15dea7a49a330f5d8ae442c3eb32419d49@65.108.15.170:36656,7e0534cc92832ce8b499ffc662a9b73d2c0351a6@135.181.162.138:27001,2f58a44c9ce9dcdf81e2eaed7cd808ebefe222a7@38.242.243.111:26656,fdeb051aae6f555150bb4cf685719879f21cd3e4@217.13.223.167:36656,12f6b84a23b054a6591c647c2a4456c40af65cce@5.9.147.22:24656,77cf0280cec16e6cf51ac3a767fc1cccd238694f@195.201.164.215:36656,ff49533061cca9b6c649693dba4e4c4769fa1f9f@95.216.7.169:60756,d84fbf48ce0773f207e8ab203d11ae644aa018df@65.108.192.123:17656,4e4f87cfa1993f4f3f7645c41f469987cafdf960@85.10.202.135:12656,6a7ba7eca935a76e02b5bbb9caf149a41da9af12@144.76.27.79:46656,f06f794dcc5964197da0e13709d71ea5e0f5b7f1@88.99.3.158:11156,875ba943654b8330d976ec97b5fcc8b9249bdf91@95.216.211.195:26656,a338c0095357e2e394b70da2356249ae69bc0756@65.109.52.156:16656,a6f4fd8efe8a575a15e25652ecebce3fa1ed62a0@213.239.217.52:35656,1721625b6e6fa29c7e172c1b99665b759a8b7877@95.216.204.255:21656,212f50ece90eb53b95b0115600bea233e0c5bec1@65.108.124.54:34656,653f801ff91cfa9ef9595e0d96cf4ee24827e9d8@65.108.229.225:34656,6d234906bc80f4a0a0124dd49692eafa1c5f04ae@49.12.33.189:26656,dea00215e54c4098a4f194a7ecd43e24ea99336f@88.99.95.81:26656,9cd6d2477d278ef6ccffa5cc4e22fd0d9489cd23@85.10.199.157:34656,5191b57c1bd202df86b67b9c7538efcf9e5c0c2a@135.181.89.99:15656,f1c042fca05e4bfb9a6da1cccaa5108a26ea1e0f@65.108.104.167:28656,7d8e56fc61dd4b34077e96d73f7af9f738cbf425@95.216.208.101:31656,0c31077af45cb4f0424e58c91b0a917c36a90fd9@65.108.195.235:16656,149494ff870b80a3a84109c098eaf48eea12d812@159.148.146.132:26656,76895e84873db23aa366296acc6900e1dd980f43@195.201.237.185:22656,f7fcda07044dc64cec2f6dca9da0c37a254bbae8@138.201.127.91:26676,6fa19dbe0236fc9328513ced95d9dd6f8330dbf3@34.160.118.165:26656,c630e7695e89074bf25a49afac7aca33feca9fd2@95.217.216.88:26656,bf16e96a383f317bdc40cdebfdf2a40a7b3d5c9a@142.132.166.131:26656,75a9570b82474af11fc8c895f9da1ecb5da0c73f@95.216.143.237:19656,30ce3c648a62735422c9b90c706796ae4ad592b2@95.216.241.112:41656,a6ef0e8544ee212cb6e571f8bc1562e7774bd2c5@88.198.34.226:11056,527c0753c83a5a89f5b51f50151b51a0d8638f7e@113.30.189.23:26656,3251c24959ff2f3fd69020413c985cff432ea3ce@65.21.245.112:13656,0d1a964bbe844ab45a0ec93ffed81945e588f6b9@5.161.86.214:26656,43edb5ddb2085727d6f6c9d0b8d6f3e4e62bf2bf@135.181.33.68:14656,eec3daeed105dcd5647d1fc24ef8f1d0f404f2fe@167.235.21.149:29656,93b218e53303ca91b7bb4f22edbb858496b1b434@65.108.6.45:60756,dbea2239b43c9e45913c22ad091abb8aaf7db469@75.119.159.159:33656,48736e36e6fdbb81c7f4389ee69a85c819b1e3e9@65.108.206.118:60756,f1b073a14dedb0fa7fb6057f7effb8559dd91154@23.121.249.57:26656,6d02cb789f1390cbb21882f7075955b38a9bd0bc@194.163.164.52:60756,d2aa45ac84cf4136182f8012b974c3e1ba762eda@65.109.53.60:56656,d2e951f1b808d95c4437762c452841fa400ec86f@139.59.33.196:26656,5ed24b6ace024919dc5035a7e650af0e5a2166d5@144.76.97.251:38816,d0a4a269b4f62a3523f403ff1812f95013b7d7a1@57.128.133.15:26656,a47375da7f790427c69103d363e4f8de4a6acfac@5.199.143.159:36656,7ecbed6c667415adc67648efe3b56e0bfafca532@217.79.187.96:26656,9954c801a7019c5e4d7d762d4877866f7fd2a44e@176.9.106.43:36656,7b2686cb07c742b0d266c25e043054e95f4cc2c0@65.108.235.107:41656,27c172e3036cc778a592a418b818af271c2d3233@190.2.155.67:32656,3e5ba61e8481c6c71d3f2cc022dd6671ed7cacf8@65.21.170.3:41656,54756019bbc900b882b302786222978928d96d9e@65.109.65.210:41656,98a1522fc5c2c200f8363ba5885771e7ec1ab5c7@95.217.211.32:26656,eac23aa96a29949a033f4f8677ed43070a4f5f04@65.109.48.19:26556,101c8fd5e3714c8d371de8c130a84032a3811c3c@95.217.211.135:13656,64719020049e4eca90332bf77ba42443e2963ef9@65.21.248.203:22656,cdc40dd0b56a9b58a155856a99fee3ff8c037076@65.21.196.153:46656,15bb9edc16710d321163e7ef8b9a44959dd7e657@65.108.126.46:30656,d312ba9da73e07c88918c56908e84ba28907808a@65.108.69.68:26858,4570f274ac45e9ab114d5a467e18fa29a305b25f@135.181.1.109:41656,ff6201a652a4c1ee7c3991bb6fc1b8885eb9f357@89.163.152.83:26256,5c08a5f53bf1984dcb5e2a461027c8f847302c9c@80.79.5.162:26656,b8cd2397920784facf0bb6cd4e30bb477f45124f@167.86.68.204:36656,a08389b85b424dd5df4fb889ff1e6d32c692e325@65.21.227.78:30656,45cc764ce4547208c21f62340a280cff1f2a4ab5@5.9.147.185:26156,8a86d39f08c47ed0ef2bd21606f16817744a3742@38.242.203.117:26656,1f7f58f130ea9c89be44fd60554d5e97da56c395@206.221.181.234:56656,0ae35c02d8b76de9e8af1ec27df2aa446485c774@167.86.94.71:26656,7da6c90fe420bca73b5274884236134acf49d565@35.168.32.254:26656,b7a2ef504e66b006ff29857fd85f1da4a40716d2@5.161.78.112:26656,26da35392bb852b97beadd8339e247ba298d285d@65.108.252.216:56656,7f6d28e4d723fa167bc134cdcab57058ee7d52dd@92.255.176.91:656,0e9f303834a5d1f3be0babd5466725b3609ebc82@65.21.141.246:28656,4977214dacb3713797653c1bc07b5982bcc91649@142.132.253.112:51656,40b5478c2e1500cdbce74701c94fdb3652f29e58@128.199.250.116:26656,8e07eedc120abbc554e767bcf1b37b12792bd297@65.21.79.97:26656,483003c31c10e10957d79b19e7da49aae225159e@65.108.152.201:26656,7761efa2f40717a8f557bba48d6e5458d167be1c@95.217.224.252:26656,0f64a56a1d4a4fa1407f2ac4533f2de67a0959d1@95.217.144.25:15609,812ac9e6b05d1b610613429277e5fef4da735753@46.228.199.8:26656,0569a7ff152236cc9efed170487bcdf54c17e4cf@174.138.101.66:44256,6cd86fc60dbee31217b3132f56f18e1f1054f278@38.242.159.228:26656,5171aad5f862d474b36fc8049be3339068c96cc9@165.232.151.144:26656,f786d8722a3f5b7dcc45714d0fc39ed088d6e2c5@94.250.203.3:6656,bad97b4dc6178b26d7d0e9667f6745946a9d2705@65.109.85.170:40656,1d3bb209dfc7fe953fb8fa37774bab34016dd75c@185.245.183.85:26656,37ba718e5cec3c1034dbda32e1e6c73ab6f6278d@143.110.224.162:26656,0cccef180d7597bbeef7d2b80d52913ab205879f@65.108.193.133:26656,8a8bbec0c685fdec2a2f67d0f9925faf8480371a@65.109.80.176:11656,f0908ffac98c2da231b927e20d480f0af84f2a2f@65.21.125.223:656,afbed8b52881b2f783df0cb07865a4da2fbbdf5e@167.235.243.27:26656,d01b95656566e3f2d6bffd2d7b0893bac3ad7828@149.102.146.252:26656,e9e671e22d794a4f80e32133905c83585b057a5d@86.48.3.0:26656,3f8fcc31b9f24cb9b4103d0200fd2f66377dcf06@65.109.58.243:26656,bf02cb5501f2c4ca75d08af8037e3a3eadf6e0a8@95.165.162.224:26656,228a33332d579dc6aff1b79dad9f58faa04b1eb2@34.170.240.35:26656,bf1ce546fc11c9c3b9bfab0e84807212c096de36@51.91.145.100:26656,0093910479011e859d6a1b7250555490ac987eb2@149.102.140.217:41656,e87b6771feff9f3c41e23a7c1e42b507345505fb@194.34.232.99:26656,61f824be9bdfe9a73b55ad162a9ed0bfe9121bbe@38.242.147.76:26656,a4eefa82608b31b55b70307f3db0d88261d8ed9b@154.53.57.72:26656,3511b4bffe4d804065181625b32e2507934fdb05@82.208.20.137:26656,6e96c0de6e437708158243153be68496d5a50119@38.242.155.23:26656,c6dcaf5c1d59c696a5b93f53cc5a855b2399f09c@149.102.146.49:26656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.gitopia/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${GITOPIA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${GITOPIA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${GITOPIA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${GITOPIA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${GITOPIA_PORT}660\"%" $HOME/.gitopia/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${GITOPIA_PORT}317\"%; s%^address = \":8080\"%address = \":${GITOPIA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${GITOPIA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${GITOPIA_PORT}091\"%" $HOME/.gitopia/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.gitopia/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.gitopia/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.gitopia/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.gitopia/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utlore\"/" $HOME/.gitopia/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.gitopia/config/config.toml

# reset
gitopiad tendermint unsafe-reset-all --home $HOME/.gitopia

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/gitopiad.service > /dev/null <<EOF
[Unit]
Description=gitopia
After=network-online.target

[Service]
User=$USER
ExecStart=$(which gitopiad) start --home $HOME/.gitopia
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable gitopiad
sudo systemctl restart gitopiad

echo '=============== SETUP FINISHED ==================='
