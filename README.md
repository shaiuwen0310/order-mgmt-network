# order-mgmt 網路流程
### 概況
* 規劃成感覺可以放到CCE上的結構
* 增加調整ca與peer節點之設定檔
* 指令盡量改成參數化，分成內部（xxx-cmd.sh）、外部參數（xxx-shell.sh），放到CCE上時要調整內部參數，xxx-shell.sh預期可用任何方式來執行
* 提取參數出來，由xxx-shell.sh帶入
* 刪除.env
* orderer節點減少成三個
* peer節點包含外部鏈碼之功能
* ca節點調整憑證過期日為30年
* peer有org1 org2，各自有自己的api（因為gateway不同）
### 本地操作流程
* ./ca-start-server.sh，啟動ca節點
* ./ca-shell.sh，產生憑證材料
* ./genfile-shell.sh，產生初始區塊、channel.tx檔案
* ./peer-start-server.sh，啟動peer節點
* ./orderer-start-server.sh，啟動orderer節點
* ./cli-start-server.sh，啟動cli節點
* ./createchannel-shell.sh，建立通道區塊、peer節點加入通道、添加anchor節點
* 在`order-mgmt-chaincode專案`執行`./pkgcc-shell.sh`，將打包peer連結外部鏈碼所需的config檔到order-mgmt-network專案中（應該是放obs前就要打包好，並且安裝完後還要進到peer中一一修改）
* ./deploycc-1nd-shell.sh，安裝合約config檔、查詢peer節點有哪些鏈碼
* 複製`./deploycc-1nd-shell.sh`的package_id，並到`order-mgmt-chaincode專案`的docker-compose`環境變數`使用
* 在`order-mgmt-chaincode專案`啟動所有外部鏈碼服務：docker-compose up -d
* 進到peer的storage資料夾調整connection.json檔，根據`order-mgmt-chaincode專案`的docker-compose的環境變數`CHAINCODE_SERVER_ADDRESS`
* ./deploycc-2nd-shell.sh，`記得PACKAGE_ID要更改！！！`各組織同意鏈碼運行
* ./deploycc-3nd-shell.sh，任意組織將鏈碼commit到通道上（這裡有policy及需要各組織peer的問題）
* 可以先在cli中使用test-shell.sh的指令，確認可以使用
* 調整`order-mgmt-node-api專案`的gateway設定檔，調整節點ip與Admin帳號的私鑰
* 在`order-mgmt-node-api專案`啟動所有api服務：docker-compose up -d

### 需要再討論的狀況
* policy設定成`"OR('Org1MSP.member','Org2MSP.member')"`，在deploycc-2nd-shell.sh、deploycc-3nd-shell.sh帶入參數
* peer lifecycle chaincode commit時，`--peerAddresses`依舊要設定兩個組織的peer才可以，否則會有ENDORSEMENT_POLICY_FAILURE，目前寫死--peerAddresses＝peer0-org2在deploycc-3nd-cmd.sh中
* node api無token、https

### 使用的port號
* orderer0-org0：7050, 17050
* orderer1-org0：8050, 18050 
* orderer2-org0：9050, 19050
* peer0-org1：7051, 7052, 17051
* peer1-org1：8051, 8052, 18051
* peer0-org2：9051, 9052, 19051
* peer1-org2：10051, 10052, 20051
* ca-org0：7054, 17054
* ca-org1：8054, 18054
* ca-org2：9054, 19054
* order-mgmt-node-api-org1：5008
* order-mgmt-node-api-org2：5009

### 節點之容器內的資料夾(config and backup)
* ca
```
/etc/hyperledger/fabric-ca-server # ls 
IssuerPublicKey   IssuerRevocationPublicKey   fabric-ca-server-config.yaml   fabric-ca-server.db   msp/
```
* peer
```
/var/hyperledger/production # ls
chaincodes/   externalbuilder/   ledgersData/   lifecycle/   transientstore/

/etc/hyperledger/fabric # ls
core.yaml/  msp/  tls/
```
* orderer
```
/var/hyperledger/production # ls
orderer/

/var/hyperledger/production/orderer # ls
chains/   etcdraft/   index/

/etc/hyperledger/fabric # ls
configtx.yaml   msp/   orderer.yaml
```

### 