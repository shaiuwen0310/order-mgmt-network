#!/bin/bash

# 
# 組織同意鏈碼執行
# 
# 參數：功能選擇, 通道名稱, 第幾個組織（從1開始）, 第幾個peer（從0開始）, peer port號（從7051開始）, 合約名稱（external-chaincode/<合約名稱>）, 合約版本（1.0.0）, PACKAGE_ID, 合約序號（從1開始）, POLICY
# 


function approvechaincode(){
  echo "approve ${CC_NAME} running on channel '${CHANNEL_NAME}'"
  peer lifecycle chaincode approveformyorg -o ${CONNECT_ORDERER} --tls ${CORE_PEER_TLS_ENABLED} --cafile ${ORDERER_CA} --channelID ${CHANNEL_NAME} --name ${CC_NAME} --version ${VERSION} --package-id ${PACKAGE_ID} --sequence ${CC_SEQUENCE} --signature-policy ${POLICY}
  res=$?
  cat log.txt

  if [ $res -ne 0 ]; then
    echo "===================== failed to approve '${CC_NAME}' running on ${CHANNEL_NAME} ===================== "
    exit 1
  fi
}

function checkapprovechaincode(){
  echo "check approved ${CC_NAME} on channel '${CHANNEL_NAME}'"

  peer lifecycle chaincode checkcommitreadiness -o ${CONNECT_ORDERER} --channelID ${CHANNEL_NAME} --tls ${CORE_PEER_TLS_ENABLED} --cafile ${ORDERER_CA} --name ${CC_NAME} --version ${VERSION} --sequence ${CC_SEQUENCE} --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles ${PEER_TLS_CERT} --signature-policy ${POLICY}  --output json
  res=$?
  cat log.txt

  if [ $res -ne 0 ]; then
    echo "===================== ${CC_NAME} has failed to be approved on ${CHANNEL_NAME} ===================== "
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
PACKAGE_ID=${8}
CC_SEQUENCE=${9}
POLICY=${10} # "AND('Org1MSP.member')"

. scripts/args.sh

if [ "${MODE}" == "approvechaincode" ]; then
  approvechaincode
elif [ "${MODE}" == "checkapprovechaincode" ]; then
  checkapprovechaincode
else
  echo "wrong mode to operate BC"
  exit 1
fi

