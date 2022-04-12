#!/bin/bash

docker-compose -f ./docker/docker-compose-ca.yaml up -d 2>&1

docker ps -a

if [ $? -ne 0 ]; then
    echo $?echo "ERROR !!!! 無法啟動CA SERVER..."
    exit 1
fi

# docker-compose -f ./docker/docker-compose-ca.yaml down

# cd ~/go/src/github.com/hyperledger/order-mgmt/order-mgmt-network/storage/org0/ca-org0
# sudo rm -rf msp/ ca-cert.pem fabric-ca-server.db IssuerPublicKey IssuerRevocationPublicKey tls-cert.pem

# cd ~/go/src/github.com/hyperledger/order-mgmt/order-mgmt-network/storage/org1/ca-org1
# sudo rm -rf msp/ ca-cert.pem fabric-ca-server.db IssuerPublicKey IssuerRevocationPublicKey tls-cert.pem

# cd ~/go/src/github.com/hyperledger/order-mgmt/order-mgmt-network/storage/org2/ca-org2
# sudo rm -rf msp/ ca-cert.pem fabric-ca-server.db IssuerPublicKey IssuerRevocationPublicKey tls-cert.pem

# cd ~/go/src/github.com/hyperledger/order-mgmt/order-mgmt-network/organizations
# sudo rm -rf *
