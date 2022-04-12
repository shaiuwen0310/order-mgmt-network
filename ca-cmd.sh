#!/bin/bash

#
# ！！！依照test-network做調整, test-network與test-network-k8s帶的變數不同
# 

# 
# 設定: orderer組織為org0, peer組織從org1開始遞增
# 
# ca名稱：ca-org0
# orderer名稱：orderer0-org0 ～ orderer4-org0
# Admin名稱：Admin0@org0.company.com ～ Admin1@org0.company.com
# 
# 
# ca名稱：ca-org1
# peer名稱：peer0-org1 ~ peer1-org1
# Admin名稱：Admin0@org1.company.com ～ Admin1@org1.company.com
# User名稱：User0@org1.company.com ～ User1@org1.company.com
# 

# 
# 帶入參數：
# 第幾個組織（從0開始）, 該組織中第幾個角色（從0開始）, 該組織CA服務的port
# 參考ca-shell帶參方式
# 

# orderer, peer組織都會用到
function enrollCA() {
  ORG=org${1}
  BOOTSTRAP=admin${1}:adminpw${1}
  PORT=${2}
  CA_NAME=ca-${ORG}
  CA_URL=https://${BOOTSTRAP}@localhost:${PORT}
  TLS_CERTFILES=${PWD}/storage/${ORG}/ca-${ORG}/tls-cert.pem
  
  echo "Enrolling the ${ORG} CA admin"

  if [ ${ORG} =  'org0' ]; then
    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/org0.company.com/
  else
    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/${ORG}.company.com/
  fi

  if [ ! -d "${FABRIC_CA_CLIENT_HOME}" ]; then
    mkdir -p ${FABRIC_CA_CLIENT_HOME}
  else
    echo "Folder exist: ${FABRIC_CA_CLIENT_HOME}"
    exit 0
  fi

  set -x
  fabric-ca-client enroll -u ${CA_URL} --caname ${CA_NAME} --tls.certfiles ${TLS_CERTFILES}
  res=${?}
  { set +x; } 2>/dev/null
  echo ${res}

  echo "NodeOUs: 
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-${PORT}-ca-${ORG}.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-${PORT}-ca-${ORG}.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-${PORT}-ca-${ORG}.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-${PORT}-ca-${ORG}.pem
    OrganizationalUnitIdentifier: orderer" >${FABRIC_CA_CLIENT_HOME}/msp/config.yaml

}

# 只有peer組織會用到
function regdEnrollPeer(){
  ORG=org${1}
  PEER_NUMBER=${2}
  ID_NAME=peer${PEER_NUMBER}
  ID_SECRET=peer${PEER_NUMBER}pw
  BOOTSTRAP=${ID_NAME}:${ID_SECRET}
  PORT=${3}
  CA_NAME=ca-${ORG}
  CA_URL=https://${BOOTSTRAP}@localhost:${PORT}
  TLS_CERTFILES=${PWD}/storage/${ORG}/ca-${ORG}/tls-cert.pem

  if [ ${ORG} = 'org0' ]; then
    echo "colud not use this function for ${ORG}"
    exit 0
  fi

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/${ORG}.company.com

  PEER_HOST_NAME=${ID_NAME}-${ORG}
  PEER_MSP_FOLDER=${FABRIC_CA_CLIENT_HOME}/peers/${PEER_HOST_NAME}/msp
  PEER_TLS_FOLDER=${FABRIC_CA_CLIENT_HOME}/peers/${PEER_HOST_NAME}/tls

  if [ ! -d "${FABRIC_CA_CLIENT_HOME}" ]; then
    echo "Folder doesn't exist: ${FABRIC_CA_CLIENT_HOME}"
    exit 0
  fi


  echo "Registering ${ID_NAME}"
  
  set -x
  fabric-ca-client register --caname ${CA_NAME} --id.name ${ID_NAME} --id.secret ${ID_SECRET} --id.type peer --tls.certfiles ${TLS_CERTFILES}
  res=${?}
  { set +x; } 2>/dev/null
  if [ ${res} -ne 0 ]; then
    echo "register error!"
    exit 0
  fi

  echo "Generating the ${ID_NAME} msp"
  set -x
  fabric-ca-client enroll -u ${CA_URL} --caname ${CA_NAME} -M ${PEER_MSP_FOLDER} --csr.hosts ${PEER_HOST_NAME} --tls.certfiles ${TLS_CERTFILES}
  { set +x; } 2>/dev/null

  cp ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml ${PEER_MSP_FOLDER}/config.yaml

  echo "Generating the ${ID_NAME}-tls certificates"
  set -x
  fabric-ca-client enroll -u ${CA_URL} --caname ${CA_NAME} -M ${PEER_TLS_FOLDER} --enrollment.profile tls --csr.hosts ${PEER_HOST_NAME} --csr.hosts localhost --tls.certfiles ${TLS_CERTFILES}
  { set +x; } 2>/dev/null

  cp ${PEER_TLS_FOLDER}/tlscacerts/* ${PEER_TLS_FOLDER}/ca.crt
  cp ${PEER_TLS_FOLDER}/signcerts/* ${PEER_TLS_FOLDER}/server.crt
  cp ${PEER_TLS_FOLDER}/keystore/* ${PEER_TLS_FOLDER}/server.key

  if [ ! -d "${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts" ]; then
    mkdir -p ${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts
    cp ${PEER_TLS_FOLDER}/tlscacerts/* ${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts/ca.crt
  fi

  if [ ! -d "${FABRIC_CA_CLIENT_HOME}/tlsca" ]; then
    mkdir -p ${FABRIC_CA_CLIENT_HOME}/tlsca
    cp ${PEER_TLS_FOLDER}/tlscacerts/* ${FABRIC_CA_CLIENT_HOME}/tlsca/tlsca.${ORG}.company.com-cert.pem
  fi

  if [ ! -d "${FABRIC_CA_CLIENT_HOME}/ca" ]; then
    mkdir -p ${FABRIC_CA_CLIENT_HOME}/ca
    cp ${PEER_MSP_FOLDER}/cacerts/* ${FABRIC_CA_CLIENT_HOME}/ca/ca.${ORG}.company.com-cert.pem
  fi

}

# 只有peer組織會用到
function regdEnrollUser() {
  ORG=org${1}
  USER_NUMBER=${2}
  ID_NAME=User${USER_NUMBER}
  ID_SECRET=User${USER_NUMBER}pw
  BOOTSTRAP=${ID_NAME}:${ID_SECRET}
  PORT=${3}
  CA_NAME=ca-${ORG}
  CA_URL=https://${BOOTSTRAP}@localhost:${PORT}
  TLS_CERTFILES=${PWD}/storage/${ORG}/ca-${ORG}/tls-cert.pem

  if [ ${ORG} = 'org0' ]; then
    echo "colud not use this function for ${ORG}"
  fi

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/${ORG}.company.com

  USER_HOST_NAME=${ID_NAME}@${ORG}.company.com
  USER_MSP_FOLDER=${FABRIC_CA_CLIENT_HOME}/users/${USER_HOST_NAME}/msp

  if [ ! -d "${FABRIC_CA_CLIENT_HOME}" ]; then
    echo "Folder doesn't exist: ${FABRIC_CA_CLIENT_HOME}"
    exit 0
  fi


  echo "Registering ${ID_NAME}"
  set -x
  fabric-ca-client register --caname ${CA_NAME} --id.name ${ID_NAME} --id.secret ${ID_SECRET} --id.type client --tls.certfiles ${TLS_CERTFILES}
  res=${?}
  { set +x; } 2>/dev/null
  if [ ${res} -ne 0 ]; then
    echo "register error!"
    exit 0
  fi

  echo "Generating the ${ID_NAME} msp"
  set -x
  fabric-ca-client enroll -u ${CA_URL} --caname ${CA_NAME} -M ${USER_MSP_FOLDER} --tls.certfiles ${TLS_CERTFILES}
  { set +x; } 2>/dev/null

  cp ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml ${USER_MSP_FOLDER}/config.yaml

}

# orderer, peer組織都會用到
function regdEnrollAdmin() {
  ORG=org${1}
  ADMIN_NUMBER=${2}
  ID_NAME=Admin${ADMIN_NUMBER}
  ID_SECRET=Admin${ADMIN_NUMBER}pw
  BOOTSTRAP=${ID_NAME}:${ID_SECRET}
  PORT=${3}
  CA_NAME=ca-${ORG}
  CA_URL=https://${BOOTSTRAP}@localhost:${PORT}
  TLS_CERTFILES=${PWD}/storage/${ORG}/ca-${ORG}/tls-cert.pem

  if [ ${ORG} =  'org0' ]; then
    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/org0.company.com
  else
    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/${ORG}.company.com
  fi

  ADMIN_HOST_NAME=${ID_NAME}@${ORG}.company.com
  ADMIN_MSP_FOLDER=${FABRIC_CA_CLIENT_HOME}/users/${ADMIN_HOST_NAME}/msp

  if [ ! -d "${FABRIC_CA_CLIENT_HOME}" ]; then
    echo "Folder doesn't exist: ${FABRIC_CA_CLIENT_HOME}"
    exit 0
  fi


  echo "Registering the org admin: ${ORG} ${ID_NAME}"
  set -x
  fabric-ca-client register --caname ${CA_NAME} --id.name ${ID_NAME} --id.secret ${ID_SECRET} --id.type admin --tls.certfiles ${TLS_CERTFILES}
  res=${?}
  { set +x; } 2>/dev/null
  if [ ${res} -ne 0 ]; then
    echo "register error!"
    exit 0
  fi

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u ${CA_URL} --caname ${CA_NAME} -M ${ADMIN_MSP_FOLDER} --tls.certfiles ${TLS_CERTFILES}
  { set +x; } 2>/dev/null

  cp ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml ${ADMIN_MSP_FOLDER}/config.yaml

}

# 只有orderer組織會用到
function regdEnrollOrderer() {
  ORG=org${1}
  ORDERER_NUMBER=${2}
  ID_NAME=orderer${ORDERER_NUMBER}
  ID_SECRET=orderer${ORDERER_NUMBER}pw
  BOOTSTRAP=${ID_NAME}:${ID_SECRET}
  PORT=${3}
  CA_NAME=ca-${ORG}
  CA_URL=https://${BOOTSTRAP}@localhost:${PORT}
  TLS_CERTFILES=${PWD}/storage/${ORG}/ca-${ORG}/tls-cert.pem

  if [ ${ORG} != 'org0' ]; then
    echo "colud not use this function for ${ORG}"
  fi

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/${ORG}.company.com

  ORDERER_HOST_NAME=${ID_NAME}-${ORG}
  ORDERER_MSP_FOLDER=${FABRIC_CA_CLIENT_HOME}/orderers/${ORDERER_HOST_NAME}/msp
  ORDERER_TLS_FOLDER=${FABRIC_CA_CLIENT_HOME}/orderers/${ORDERER_HOST_NAME}/tls

  if [ ! -d "${FABRIC_CA_CLIENT_HOME}" ]; then
    echo "Folder doesn't exist: ${FABRIC_CA_CLIENT_HOME}"
    exit 0
  fi


  echo "Registering ${ID_NAME}"
  set -x
  fabric-ca-client register --caname ${CA_NAME} --id.name ${ID_NAME} --id.secret ${ID_SECRET} --id.type orderer --tls.certfiles ${TLS_CERTFILES}
  res=${?}
  { set +x; } 2>/dev/null
  if [ ${res} -ne 0 ]; then
    echo "register error!"
    exit 0
  fi

  echo "Generating the ${ID_NAME} msp"
  set -x
  fabric-ca-client enroll -u ${CA_URL} --caname ${CA_NAME} -M ${ORDERER_MSP_FOLDER} --csr.hosts ${ORDERER_HOST_NAME} --csr.hosts localhost --tls.certfiles ${TLS_CERTFILES}
  { set +x; } 2>/dev/null

  cp ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml ${ORDERER_MSP_FOLDER}/config.yaml

  echo "Generating the ${ID_NAME}-tls certificates"
  set -x
  fabric-ca-client enroll -u ${CA_URL} --caname ${CA_NAME} -M ${ORDERER_TLS_FOLDER} --enrollment.profile tls --csr.hosts ${ORDERER_HOST_NAME} --csr.hosts localhost --tls.certfiles ${TLS_CERTFILES}
  { set +x; } 2>/dev/null

  cp ${ORDERER_TLS_FOLDER}/tlscacerts/* ${ORDERER_TLS_FOLDER}/ca.crt
  cp ${ORDERER_TLS_FOLDER}/signcerts/* ${ORDERER_TLS_FOLDER}/server.crt
  cp ${ORDERER_TLS_FOLDER}/keystore/* ${ORDERER_TLS_FOLDER}/server.key

  mkdir -p ${ORDERER_MSP_FOLDER}/tlscacerts
  cp ${ORDERER_TLS_FOLDER}/tlscacerts/* ${ORDERER_MSP_FOLDER}/tlscacerts/tlsca.company.com-cert.pem

  if [ ! -d "${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts" ]; then
    mkdir -p ${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts
    cp ${ORDERER_TLS_FOLDER}/tlscacerts/* ${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts/tlsca.company.com-cert.pem
  fi

}