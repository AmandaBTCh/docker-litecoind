# docker-litecoind
Docker Image for Litecoin

### Quick Start
Create a litecoind-data volume to persist the litecoind blockchain data, should exit immediately. The litecoind-data container will store the blockchain when the node container is recreated (software upgrade, reboot, etc):
```
docker volume create --name=litecoind-data
```
Create a litecoin.conf file and put your configurations
```
mkdir -p ~/.ltcdocker
nano /home/$USER/.ltcdocker/litecoin.conf
```

Run the docker image
```
docker run -v litecoind-data:/litecoin --name=litecoind-node -d \
      -p 8333:8333 \
      -p 8332:8332 \
      -v /home/$USER/.ltcdocker/litecoin.conf:/litecoin/.litecoin/litecoin.conf \
      unibtc/docker-litecoind
```

Check Logs
```
docker logs -f litecoind-node
 ```