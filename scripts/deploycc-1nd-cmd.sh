#!/bin/bash

# 
# 安裝外部鏈碼config檔到peer上
# 
# 參數：功能選擇, 通道名稱, 第幾個組織（從1開始）, 第幾個peer（從0開始）, peer port號（從7051開始）, 合約名稱（external-chaincode/<合約名稱>）
# 


function installchaincode(){
  echo "install ${CC_NAME} on ${CORE_PEER_ADDRESS}"
  peer lifecycle chaincode install ${CC_CONFIG_FULL_PATH} --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles ${PEER_TLS_CERT} >&log.txt
  res=$?
  cat log.txt
  if [ $res -ne 0 ]; then
    echo "===================== ${CORE_PEER_ADDRESS} has failed to install '${CC_NAME}' ===================== "
    exit 1
  fi
}

function checkinstalledchaincode(){
  echo "query installed chaincode on ${CORE_PEER_ADDRESS}"
  peer lifecycle chaincode queryinstalled --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles ${PEER_TLS_CERT} --output json
  res=$?
  cat log.txt
  if [ $res -ne 0 ]; then
    echo "===================== ${CORE_PEER_ADDRESS} has failed to install '${CC_NAME}' ===================== "
    exit 1
  fi
}

MODE=${1}
CHANNEL_NAME=${2}
MSPID_SEQ=${3}
ORG=org${3}
PEER=peer${4}
PEER_NAME=${PEER}-${ORG}
PEER_PORT=${5}
CC_NAME=${6}

. scripts/args.sh

if [ "${MODE}" == "installchaincode" ]; then
  installchaincode
elif [ "${MODE}" == "checkinstalledchaincode" ]; then
  checkinstalledchaincode
else
  echo "wrong mode to operate BC"
  exit 1
fi