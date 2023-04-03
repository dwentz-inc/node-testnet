### Tutorial gitshock cartenz
### Install package yang dibutuhkan
```
sudo apt update && sudo apt upgrade -y
sudo apt install build-essential -y
sudo apt install micro -y
sudo add-apt-repository -y ppa:ethereum/ethereum -y
sudo apt update -y
sudo apt install ethereum -y
sudo apt install jq -y
```
### Installing Go
```
ver="1.20.2" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version
````
### Update protocol Ethereum
```
go install github.com/protolambda/eth2-testnet-genesis@latest
```
```
go install github.com/protolambda/eth2-val-tools@latest
```
### Install Program
```
mkdir cartenz
```
```
cd cartenz 
```
```
wget https://github.com/gitshock-labs/testnet-list/releases/download/Iteration-70.a/cartenz-iteration-70.a.zip
```
```
unzip cartenz-iteration-70.a.zip
```
### membuat file JWT
```
openssl rand -hex 32 | tr -d "\n" > "jwt.hex" 
```
### Konfigurasi GETH

* membuat account

`Simpan file UTC`
```
geth account new --datadir "data"
```
* custom genesis
```
geth --datadir /$HOME/cartenz/data init /$HOME/cartenz/execution/genesis.json
```
* membuat consensus GETH
```
touch geth.log
```
```
nohup geth \
--http --http.api="admin,eth,net,web3" \
--http.port 8545 \
--http.addr 0.0.0.0 \
--authrpc.addr 0.0.0.0 \
--authrpc.jwtsecret /root/cartenz/jwt.hex \
--authrpc.port 8551 \
--discovery.port 30303 \
--port 30303 \
--http.corsdomain=* \
--identity "dwentz" \
--http.vhosts=* \
--bloomfilter.size 2048 \
--datadir /root/cartenz/data \
--gcmode="archive" \
--networkid=1881 \
--syncmode=full \
--light.maxpeers 250 \
--metrics \
--metrics.addr 0.0.0.0 \
--maxpeers 100 \
--cache 1024 \
> /root/cartenz/geth.log &
```
` jika ingin custom port ganti pada bagian --http.port dan --port`
* menambhakan enode untuk peering
```
geth attach http://localhost:8545
```
`sesuikan port yang anda gunakan`
Lalu tambahkan peer secara manual
```
admin.addPeer("enode://0e2b41699b95e8c915f4f5d18962c0d2db35dc22d3abbebbd25fc48221d1039943240ad37a6e9d853c0b4ea45da7b6b5203a7127b5858c946fc040cace8d2d63@147.75.71.217:30303")
```
```
admin.addTrustedPeer("enode://0e2b41699b95e8c915f4f5d18962c0d2db35dc22d3abbebbd25fc48221d1039943240ad37a6e9d853c0b4ea45da7b6b5203a7127b5858c946fc040cace8d2d63@147.75.71.217:30303")
```
```
admin.peers
```
`pastikan sudah terkonek dengan githsock cartenz. Untuk keluar ketik CTRL+D`

simpan ENODE dengan perintah:
```
admin.nodeInfo.enode
```
* cek log geth
```
tail -f geth.log
```
### Konfigurasi lighthouse Beacon
* download lighthouse
```
wget https://github.com/sigp/lighthouse/releases/download/v4.0.1/lighthouse-v4.0.1-x86_64-unknown-linux-gnu-portable.tar.gz
```
```
tar -xvf lighthouse-v4.0.1-x86_64-unknown-linux-gnu-portable.tar.gz
```
```
rm -rf lighthouse-v4.0.1-x86_64-unknown-linux-gnu-portable.tar.gz
```
```
mv lighthouse /usr/local/bin
```
```
touch beacon1.log
```
```
screen -S beacon
```
* konfigurasi Beacon
```
nohup lighthouse beacon \
--eth1 \
--http \
--testnet-dir /$HOME/cartenz/consensus \
--datadir "/$HOME/cartenz/data" \
--http-allow-sync-stalled \
--execution-endpoints http://127.0.0.1:8551 \
--http-port=5052 \
--enr-udp-port=9000 \
--enr-tcp-port=9000 \
--discovery-port=9000 \
--graffiti "Dwentz-gitshock" \
--execution-jwt "/$HOME/cartenz/jwt.hex" \
--suggested-fee-recipient=0x0198d33525fa9f5dee2D2626F952D718CA482733 \
> /$HOME/cartenz/beacon1.log &
```
`ganti suggested-fee-recipient=0x019 dengan address yang didapat sebelumnya`
* mendapatkan file ENR
```
curl http://localhost:5052/eth/v1/node/identity | jq 
```
`simpan file enr- lalu klik CTRL+AD`
* cek log beacon
```
tail -f beacon1.log
```
### Konfigurasi Lighthouse
```
touch beacon2.log
```
```
screen -S lighthouse
```
```
nohup lighthouse \
--testnet-dir /$HOME/cartenz/consensus \
bn \
--datadir "/$HOME/cartenz/data/beacon" \
--eth1 \
--http \
--http-allow-sync-stalled \
--execution-endpoints "http://127.0.0.1:8551" \
--eth1-endpoints "http://127.0.0.1:8545" \
--http-address 0.0.0.0 \
--http-port 5053 \
--http-allow-origin="*" \
--listen-address 0.0.0.0 \
--enr-udp-port 9001 \
--enr-tcp-port 9001 \
--port 9001 \
--enr-address IP-NODE \
--execution-jwt "/$HOME/cartenz/jwt.hex" \
--boot-nodes="ENR ANDA,enr:-MS4QHXShZPtKwtexK2p9yCxMxDwQ-EvdH_VemoxyVyweuaBLOC_8cmOzyx7Gy-q6-X8KGT1d_rhAn_ekXnhpCkA_REHh2F0dG5ldHOIAAAAAAAAAACEZXRoMpBMfxReAmd2k___________gmlkgnY0gmlwhJNLR9mJc2VjcDI1NmsxoQJB10N42nK6rr7Q_NIJNkJFi2uo6itMTOQlPZDcCy09T4hzeW5jbmV0c4gAAAAAAAAAAIN0Y3CCIyiDdWRwgiMo,enr:-MS4QEw_RpORuoXgJ0279QuVLLFAiXevNdYtU7vR8S1CY7X9CS6tceMbaxdIIJYRmHN43ClqHtE2b0H0maSb18cm9D0Hh2F0dG5ldHOIAAAAAAAAAACEZXRoMpBMfxReAmd2k___________gmlkgnY0gmlwhJNLR9mJc2VjcDI1NmsxoQOkQIyCVHLbLjIFMjqNSJEUsbYMe4Tsv9blUWvN6Rsft4hzeW5jbmV0c4gAAAAAAAAAAIN0Y3CCIymDdWRwgiMp,enr:-LS4QExQqM_G3y2CfedjrGEbapN5Vprdy7Iq2gzfylwLW8PQf4Tf82XnQxLg9PbH8QLwsMaoWwYjTo7xHQ4oy4eCn7kBh2F0dG5ldHOIAAAAAAAAAACEZXRoMpBMfxReAmd2k___________gmlkgnY0iXNlY3AyNTZrMaEDec2pARmw1GLJHiXIDaG-6J74gZ1SyDcF_CuVUzRsmX2Ic3luY25ldHMAg3RjcIIjKoN1ZHCCIyo,enr:-Ly4QASQytrMTDShxZLaYNw_gLFKr_jgn264t812QqCIYtRXDAvLjNokixeG5nXJdCL94VcCmpF_HVIgJhgvR871pwABh2F0dG5ldHOIAAAAAAAAAACEZXRoMpBMfxReAmd2k___________gmlkgnY0gmlwhDZSKp-Jc2VjcDI1NmsxoQJ01SgLN3nyqQc-6-pvOnVL4p3TKaqTEj8xcTyyVFLk-4hzeW5jbmV0cwCDdGNwgiMsg3VkcIIjLA" \
--suggested-fee-recipient=ADDRESS ANDA  \
> /$HOME/cartenz/beacon2.log &
```
`edit bagian --boot-nodes Tambahkan enr anda yang didapat sebeumnya`

* cek log lighthouse
``` 
tail -f beacon2.log
```
`exit screen dengan CTRL+AD`
### Staking validator
```
N/A
```
