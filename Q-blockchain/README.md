<p align="center">
  <img width="270" height="auto" src="https://user-images.githubusercontent.com/108969749/201537323-e380f751-fdf5-4e2a-98c7-7139664e2df3.png">
</p>

### Spesifikasi Hardware :
NODE  | CPU     | RAM      | SSD     |
| ------------- | ------------- | ------------- | -------- |
| Testnet | 4          | 8         | 160  |

### Install docker-compose
```
sudo apt update && sudo apt upgrade -y
sudo apt install docker-compose -y
```

### Download Binary
```
git clone https://gitlab.com/q-dev/testnet-public-tools
cd testnet-public-tools/testnet-validator
```
### Hasilkan Keystore
* Membuat password untuk keystore
```
mkdir keystore
```
```
cd keystore
```
```
nano pwd.txt
```
* Membuat keystore
```
cd ..
docker run --entrypoint="" --rm -v $PWD:/data -it qblockchain/q-client:testnet geth account new --datadir=/data --password=/data/keystore/pwd.txt
```
<p align="center">
  <img width="300" height="auto" src="https://user-images.githubusercontent.com/108969749/206828337-cbf54418-1cb1-4b38-a6dc-c5cff918fc5f.jpg">
</p>

### Konfigurasi node
`Edit versi node ke 1.2.2`
 * Edit file .env
```
cp .env.example .env
```
```
nano .env
```
<p align="center">
  <img width="300" height="auto" src="https://user-images.githubusercontent.com/108969749/206828444-af548308-e993-4704-b7ff-f4df3e2fdfee.jpg">
</p>

  * Edit config.json

`address tanpa 0x dan ganti password dengan password yang sudah dibuat sebelumnya`
```
nano config.json
```
<p align="center">
  <img width="300" height="auto" src="https://user-images.githubusercontent.com/108969749/206828546-b560236b-68c6-405b-9865-4c82fc18475e.jpg">
</p>

### Mendapatkan faucet Q

[Go to Faucet](https://faucet.qtestnet.org/)

### Stake auto 2Q 
```
docker run --rm -v $PWD:/data -v $PWD/config.json:/build/config.json qblockchain/js-interface:testnet validators.js
```
### Extract Private key
```
cd ..
chmod +x run-js-tools-in-docker.sh
./run-js-tools-in-docker.sh
npm install
```
```
cd js-tools
chmod +x extract-geth-private-key.js
node extract-geth-private-key <Wallet_Address> ../testnet-validator/ <password>
```
`ganti wallet address dan password`

### Daftar validator

[Daftar disini](https://itn.qdev.li/)

Buat nama ITN untuk validator dibagian `set ethstats identifier`
 
### Menambhakan validator ke consensus
```
nano docker-compose.yaml
```
* Membuat nama validator

`ganti ITN-testname`
```
image: $QCLIENT_IMAGE
 entrypoint: ["geth", "--ethstats=ITN-testname-ecd07:qstats-testnet@stats.qtestnet.org", "--datadir=/data", ...]
```
<p align="center">
  <img width="300" height="auto" src="https://user-images.githubusercontent.com/108969749/206828856-c9e41f64-ccc5-4b4f-9585-90728741f2b9.jpg">
</p>

### Run node
```
docker-compose pull && docker-compose up -d
```
 * cek log node
```
docker-compose logs -f --tail "100"
```
 * stop node
```
docker compose down
```
