#!/bin/bash

# 
# createchannel：建立通道
# joinchannel：將peer加入通道
# setAnchorPeer：設定anchor peer到通道
# 
# 參數：功能選擇, 通道名稱, 第幾個組織（從1開始）, 第幾個peer（從0開始）, peer port號（從7051開始）
# 

function createChannel() {
  echo "create channel ${CHANNEL_NAME}"
    peer channel create -o ${CONNECT_ORDERER} -c ${CHANNEL_NAME} -f ./channel-artifacts/${CHANNEL_NAME}.tx --tls ${CORE_PEER_TLS_ENABLED} --cafile ${ORDERER_CA} >&log.txt
  res=$?
  cat log.txt
  if [ $res -ne 0 ]; then
    echo "===================== Channel '${CHANNEL_NAME}' creation failed ===================== "
    exit 1
  fi
}

function joinChannel() {
  echo "${CORE_PEER_ADDRESS} join to ${CHANNEL_NAME}"
  peer channel join -b ${CHANNEL_NAME}.block >&log.txt
  sleep 3
  res=$?
  cat log.txt
  if [ $res -ne 0 ]; then
    echo "===================== ${CORE_PEER_ADDRESS} has failed to join channel '${CHANNEL_NAME}' ===================== "
    exit 1
  fi
}

function setAnchorPeer(){
  # 抓取通道資料
  echo "Fetching the most recent configuration block for the channel ${CHANNEL_NAME}"
  set -x
  peer channel fetch config config_block.pb -o ${CONNECT_ORDERER} --ordererTLSHostnameOverride ${ORDERER_HOST} -c ${CHANNEL_NAME} --tls --cafile ${ORDERER_CA}
  res=$?
  cat log.txt
  { set +x; } 2>/dev/null
  
  if [ $res -ne 0 ]; then
    echo "===================== Fetching configuration block failed ===================== "
    exit 1
  fi
  echo

  # 將資料轉成json
  echo "Decoding config block to JSON and isolating config to ${CORE_PEER_LOCALMSPID}config.json"
  set -x
  configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${CORE_PEER_LOCALMSPID}config.json"
  res=$?
  cat log.txt
  { set +x; } 2>/dev/null

  if [ $res -ne 0 ]; then
    echo "===================== Decoding config block failed ===================== "
    exit 1
  fi
  echo

  # Modify the configuration to append the anchor peer
  echo "Generating anchor peer update transaction for Org${MSPID_SEQ} on channel ${CHANNEL_NAME}"
  set -x
  jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'${PEER_NAME}'","port": '${PEER_PORT}'}]},"version": "0"}}' ${CORE_PEER_LOCALMSPID}config.json > ${CORE_PEER_LOCALMSPID}modified_config.json
  res=$?
  cat log.txt
  { set +x; } 2>/dev/null

  if [ $res -ne 0 ]; then
    echo "===================== Generating anchor peer update transaction failed ===================== "
    exit 1
  fi
  echo

  # 比較前後差異, 最後產出{orgmsp}anchors.tx
  echo "Takes an original and modified config, and produces the config update tx"
  set -x
  configtxlator proto_encode --input "${CORE_PEER_LOCALMSPID}config.json" --type common.Config >original_config.pb
  configtxlator proto_encode --input "${CORE_PEER_LOCALMSPID}modified_config.json" --type common.Config >modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL_NAME}" --original original_config.pb --updated modified_config.pb >config_update.pb
  configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate >config_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'${CHANNEL_NAME}'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope >"${CORE_PEER_LOCALMSPID}anchors.tx"
  res=$?
  cat log.txt
  { set +x; } 2>/dev/null

  if [ $res -ne 0 ]; then
    echo "===================== Generating anchor peer update transaction failed ===================== "
    exit 1
  fi
  echo

  # 更新
  echo "Anchor peer set for org '${CORE_PEER_LOCALMSPID}' on channel '${CHANNEL_NAME}'"
  set -x
  peer channel update -o ${CONNECT_ORDERER} --ordererTLSHostnameOverride ${ORDERER_HOST} -c ${CHANNEL_NAME} -f ${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile ${ORDERER_CA} >&log.txt
  res=$?
  cat log.txt
  { set +x; } 2>/dev/null
  
  if [ $res -ne 0 ]; then
    echo "===================== Anchor peer update failed ===================== "
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

. scripts/args.sh

if [ "${MODE}" == "createchannel" ]; then
  createChannel
elif [ "${MODE}" == "joinchannel" ]; then
  joinChannel
elif [ "${MODE}" == "setanchorpeer" ]; then
  setAnchorPeer
else
  echo "wrong mode to operate BC"
  exit 1
fi