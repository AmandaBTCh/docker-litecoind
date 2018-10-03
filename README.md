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
      -p 9333:9333 \
      -p 9332:9332 \
      -v /home/$USER/.ltcdocker/litecoin.conf:/litecoin/.litecoin/litecoin.conf \
      bitsler/docker-litecoind:latest
```

Check Logs
```
docker logs -f litecoind-node
```

Auto Installation
```
sudo bash -c "$(curl -L https://git.io/fxIn9)"
```