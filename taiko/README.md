### Taiko Node Installation
### Install Docker-compose
* docker-compose
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-22-04
* docker engine

https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04

### Install Node
```
git clone https://github.com/taikoxyz/simple-taiko-node.git
cd simple-taiko-node
```
```


### Setting
```
cp .env.sample .env
```
```
nano .env
```
  scroll kebawah dan tambahkan private key EVM
Set `enable=true`

`untuk prover tambahkan Endpoint yang didaptkan dari` [infura](https://app.infura.io/dashboard/)/alchemy 
,untuk mendapatkan HTTPS sama WSS nya

### Run Node
* runing
```
 docker-compose up -d
```
* cek log node
```
docker logs -f simple-taiko-node-taiko_client_driver-1
```
```
docker logs -f l2_execution_engine
```
* setting grafana
```
http://localhost:3000/d/L2ExecutionEngine/l2-execution-engine-overview?orgId=1&refresh=10s
```
`Ganti localhost:3000 dengan ip server beserta port yang digunakan `

