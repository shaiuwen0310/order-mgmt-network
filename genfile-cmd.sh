#!/bin/bash

# 
# 帶入參數：
# configtx.yaml中要執行的段落名稱, 要建立的帳本名稱（通道名稱不可大寫）
# 參考genfile-shell帶參方式
# 

# 
# 注意：
# createGenesisBlock: 基本上只會使用一次
# createChannelTx: 能執行重複名稱, 但不知道是否會影響已被使用的檔案
# 


# Generate orderer system channel genesis block.
function createGenesisBlock(){
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi

  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"
  echo ""

  # configtx.yaml的位置
  export FABRIC_CFG_PATH=${PWD}/config/org0
  
  # OrgOrdererGenesis為configtx.yaml中的段落
  GENESIS_TAG=OrgOrdererGenesis
  CHANNEL_ID=system-channel
  OUTPUT_FILE_PATH=${PWD}/system-genesis-block/genesis.block

  if [ -f "${OUTPUT_FILE_PATH}" ]; then
    echo "Already have genesis.block"
    exit 0
  fi

  set -x
  configtxgen -profile ${GENESIS_TAG} -channelID ${CHANNEL_ID} -outputBlock ${OUTPUT_FILE_PATH}
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi

}

# Generate channel configuration
function createChannelTx(){
  ORG_CHANNEL_TAG=${1}
  CHANNEL_NAME=${2}
  OUTPUT_FILE_PATH=${PWD}/channel-artifacts/${CHANNEL_NAME}.tx

  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi

  echo "#################################################################"
  echo "######### Generating channel configuration transaction ##########"
  echo "#################################################################"
  echo ""

  # configtx.yaml的位置
  export FABRIC_CFG_PATH=${PWD}/config/org0

  set -x
  configtxgen -profile ${ORG_CHANNEL_TAG} -outputCreateChannelTx ${OUTPUT_FILE_PATH} -channelID ${CHANNEL_NAME}
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi

}


