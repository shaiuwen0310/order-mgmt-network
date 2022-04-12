#!/bin/bash

docker-compose -f ./docker/docker-compose-orderer-org0.yaml up -d 2>&1

docker ps -a

if [ $? -ne 0 ]; then
    echo $?echo "ERROR !!!! 無法啟動orderer節點..."
    exit 1
fi

# docker-compose -f ./docker/docker-compose-orderer-org0.yaml down

# cd ~/go/src/github.com/hyperledger/order-mgmt/order-mgmt-network/storage/org0/orderer0-org0
# sudo rm -rf *

# cd ~/go/src/github.com/hyperledger/order-mgmt/order-mgmt-network/storage/org0/orderer1-org0
# sudo rm -rf *

# cd ~/go/src/github.com/hyperledger/order-mgmt/order-mgmt-network/storage/org0/orderer2-org0
# sudo rm -rf *

