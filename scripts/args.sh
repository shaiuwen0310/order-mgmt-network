#!/bin/bash

# ====== 合約所需之參數 ======
# 使用的語言
LANGUAGE="golang"
# 路徑
CC_CONFIG_FULL_PATH='/opt/hyperledger/fabric/external-chaincode/'${CC_NAME}'/'${CC_NAME}'-external.tgz'


# ====== 區塊鏈操作所需之參數 ======
# 指定要連線的orderer
CONNECT_ORDERER="orderer0-org0:7050"
ORDERER_HOST="orderer0-org0"
ORDERER_CA=/opt/hyperledger/fabric/crypto/ordererOrganizations/org0.company.com/orderers/orderer0-org0/msp/tlscacerts/tlsca.company.com-cert.pem

# 連線之peer節點相關環境設定
export CORE_PEER_ADDRESS=${PEER_NAME}:${PEER_PORT} # peer0-org1:7051
export CORE_PEER_LOCALMSPID=Org${MSPID_SEQ}MSP # Org1MSP
export CORE_PEER_TLS_CERT_FILE=/opt/hyperledger/fabric/crypto/peerOrganizations/${ORG}.company.com/peers/${PEER_NAME}/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/hyperledger/fabric/crypto/peerOrganizations/${ORG}.company.com/peers/${PEER_NAME}/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/hyperledger/fabric/crypto/peerOrganizations/${ORG}.company.com/peers/${PEER_NAME}/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/hyperledger/fabric/crypto/peerOrganizations/${ORG}.company.com/users/Admin0@${ORG}.company.com/msp # 固定使用第一個Admin帳號

# CORE_PEER_TLS_ROOTCERT_FILE
PEER_TLS_CERT=/opt/hyperledger/fabric/crypto/peerOrganizations/${ORG}.company.com/peers/${PEER_NAME}/tls/ca.crt
