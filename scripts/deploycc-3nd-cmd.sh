#!/bin/bash

# 
# 組織向通道提交鏈碼，只須一個組織做一次
# 
# 參數：功能選擇, 通道名稱, 第幾個組織（從1開始）, 第幾個peer（從0開始）, peer port號（從7051開始）, 合約名稱（external-chaincode/<合約名稱>）, 合約版本（1.0.0）, 合約序號（從1開始）, POLICY
# 


function commitchaincode(){
  echo "commit ${CC_NAME} on ${PEER_NAME} on channel '${CHANNEL_NAME}'"
  
  # peer lifecycle chaincode commit -o ${CONNECT_ORDERER} --channelID ${CHANNEL_NAME} --name ${CC_NAME} --version ${VERSION} --sequence ${CC_SEQUENCE} --tls ${CORE_PEER_TLS_ENABLED} --cafile ${ORDERER_CA} --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles ${PEER_TLS_CERT} --signature-policy ${POLICY}
  peer lifecycle chaincode commit -o ${CONNECT_ORDERER} --channelID ${CHANNEL_NAME} --name ${CC_NAME} --version ${VERSION} --sequence ${CC_SEQUENCE} --tls ${CORE_PEER_TLS_ENABLED} --cafile ${ORDERER_CA} --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles ${PEER_TLS_CERT} --peerAddresses peer0-org2:9051 --tlsRootCertFiles /opt/hyperledger/fabric/crypto/peerOrganizations/org2.company.com/peers/peer0-org2/tls/ca.crt --signature-policy ${POLICY}
  res=$?
  cat log.txt

  if [ $res -ne 0 ]; then
    echo "===================== failed to commit ${CC_NAME} on ${PEER_NAME} on ${CHANNEL_NAME} ===================== "
    exit 1
  fi
}

function querycommitchaincode(){
  echo "query ${CC_NAME} on ${CORE_PEER_ADDRESS} on channel '${CHANNEL_NAME}'"

  peer lifecycle chaincode querycommitted -o ${CONNECT_ORDERER} --channelID ${CHANNEL_NAME} --tls --cafile ${ORDERER_CA} --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles ${PEER_TLS_CERT} --output json
  res=$?
  cat log.txt

  if [ $res -ne 0 ]; then
    echo "===================== failed to query ${CC_NAME} on ${PEER_NAME} on ${CHANNEL_NAME} ===================== "
    exit 1
  fi
}

MODE=${1}
CHANNEL_NAME=${2}
MSPID_SEQ=${3}
ORG=org${MSPID_SEQ}
PEER=peer${4}
PEER_NAME=${PEER}-${ORG}
PEER_PORT=${5}
CC_NAME=${6}
VERSION=${7}
CC_SEQUENCE=${8}
POLICY=${9} # "AND('Org1MSP.member')"

. scripts/args.sh

if [ "${MODE}" == "commitchaincode" ]; then
  commitchaincode
elif [ "${MODE}" == "querycommitchaincode" ]; then
  querycommitchaincode
else
  echo "wrong mode to operate BC"
  exit 1
fi

