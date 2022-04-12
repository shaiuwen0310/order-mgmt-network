#!/bin/bash

docker-compose -f ./docker/docker-compose-peer-org1.yaml up -d 2>&1

docker-compose -f ./docker/docker-compose-peer-org2.yaml up -d 2>&1

docker ps -a

if [ $? -ne 0 ]; then
    echo $?echo "ERROR !!!! 無法啟動peer節點..."
    exit 1
fi

# docker-compose -f ./docker/docker-compose-peer-org1.yaml down
# docker-compose -f ./docker/docker-compose-peer-org2.yaml down

# cd ~/go/src/github.com/hyperledger/order-mgmt/order-mgmt-network/storage/org1/peer0-org1
# sudo rm -rf *

# cd ~/go/src/github.com/hyperledger/order-mgmt/order-mgmt-network/storage/org1/peer1-org1
# sudo rm -rf *

# cd ~/go/src/github.com/hyperledger/order-mgmt/order-mgmt-network/storage/org2/peer0-org2
# sudo rm -rf *

# cd ~/go/src/github.com/hyperledger/order-mgmt/order-mgmt-network/storage/org2/peer1-org2
# sudo rm -rf *

