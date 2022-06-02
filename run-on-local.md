# 在本地端建立區塊鏈應用
此為兩個組織之應用
## 關聯專案
- [digital-assets-network](http://192.168.101.252/digital-assets-management/digital-assets-network)
- [digital-assets-chaincode](http://192.168.101.252/digital-assets-management/digital-assets-chaincode-service)
- [digital-assets-node-api](http://192.168.101.252/digital-assets-management/digital-assets-node-api)
## 下載專案
下載以上三個專案，並放置到同一資料夾中
```sh
judy@l:~/go/src/數字資產$ tree -L 1
.
├── digital-assets-cce-operate-steps
├── digital-assets-chaincode
├── digital-assets-network
└── digital-assets-node-api
```
## 啟動網路
1. 進到digital-assets-network專案
2. 啟動ca節點
3. 產生憑證材料
4. 產生初始區塊、channel.tx檔案
5. 啟動peer節點
6. 啟動orderer節點
7. 啟動cli節點
8. 建立通道區塊、peer節點加入通道、添加anchor節點
```sh
cd ~/go/src/數字資產/digital-assets-network
./ca-start-server.sh
./ca-shell.sh
./genfile-shell.sh
./peer-start-server.sh
./orderer-start-server.sh
./cli-start-server.sh
./createchannel-shell.sh
```
9. 進到digital-assets-chaincode專案
10. 打包peer連結外部鏈碼所需的config檔到digital-assets-network專案中
```sh
cd ~/go/src/數字資產/digital-assets-chaincode
./pkgcc-shell.sh
```
11. 回到digital-assets-network專案
12. 安裝合約config檔、查詢peer節點有哪些鏈碼
13. 複製package_id
```sh
cd ~/go/src/數字資產/digital-assets-network
./deploycc-1nd-shell.sh

# 複製的package_id格式應如下一行
orderform_1.0.0:d47ba1273f47bb83e73c5f06d4437bac8546a5cbe0ca6623405c051a204d7b
```
14. 重新進到digital-assets-chaincode專案
15. 開啟其中的docker-compose.yaml，並將其中的CHAINCODE_ID改成第13步的package_id
16. 啟動所有外部鏈碼服務
17. 複製docker-compose.yaml中的環境變數CHAINCODE_SERVER_ADDRESS
```sh
cd ~/go/src/數字資產/digital-assets-chaincode

# docker-compose.yaml中要調整的環境變數
CHAINCODE_ID=orderform_1.0.0:d47ba1273f47bb83e73c5f06d4437bac8546a5cbe0ca6623405c051a204d7b

docker-compose up -d

# CHAINCODE_SERVER_ADDRESS應如下，分別有四個
chaincode-orderform-peer0-org1:7052
chaincode-orderform-peer1-org1:8052
chaincode-orderform-peer0-org2:9052
chaincode-orderform-peer1-org2:10052
```
18. 回到digital-assets-network專案
19. 進到peer的storage資料夾調整connection.json檔，根據digital-assets-chaincode專案的docker-compose的環境變數CHAINCODE_SERVER_ADDRESS
```sh
cd ~/go/src/數字資產/digital-assets-network

cd ~/go/src/數字資產/digital-assets-network/storage/org1/peer0-org1
# 每次執行路徑會不同
sudo vim externalbuilder/builds/orderform_1.0.0-d47ba1273f47bb83e73c5f06d4437bac8546a5cbe0ca6623405c051a204d7b8f/release/chaincode/server/connection.json
調整成chaincode-orderform-peer0-org1:7052

cd ~/go/src/數字資產/digital-assets-network/storage/org1/peer1-org1
# 每次執行路徑會不同
sudo vim externalbuilder/builds/orderform_1.0.0-d47ba1273f47bb83e73c5f06d4437bac8546a5cbe0ca6623405c051a204d7b8f/release/chaincode/server/connection.json
調整成chaincode-orderform-peer1-org1:8052

cd ~/go/src/數字資產/digital-assets-network/storage/org2/peer0-org2
# 每次執行路徑會不同
sudo vim externalbuilder/builds/orderform_1.0.0-d47ba1273f47bb83e73c5f06d4437bac8546a5cbe0ca6623405c051a204d7b8f/release/chaincode/server/connection.json
調整成chaincode-orderform-peer0-org2:9052

cd ~/go/src/數字資產/digital-assets-network/storage/org2/peer1-org2
# 每次執行路徑會不同
sudo vim externalbuilder/builds/orderform_1.0.0-d47ba1273f47bb83e73c5f06d4437bac8546a5cbe0ca6623405c051a204d7b8f/release/chaincode/server/connection.json
調整成chaincode-orderform-peer1-org2:10052
```
20. 回到digital-assets-network專案
21. **<重要 一定要改！！！> 更改deploycc-2nd-shell.sh的PACKAGE_ID值**
22. 各組織同意鏈碼運行
23. 任意組織將鏈碼commit到通道上
```sh
cd ~/go/src/數字資產/digital-assets-network
vim deploycc-2nd-shell.sh
調整成第13步的package_id

./deploycc-2nd-shell.sh
./deploycc-3nd-shell.sh
```
24. 進入cli容器
25. 複製test-shell.sh的內容，在cli內執行，以測試區塊鏈網路已可執行
```sh
docker exec -it cli sh
複製test-shell.sh的內容來，執行測試交易
```
26. 進到digital-assets-node-api專案
27. 查找所有節點的IP
28. 查看Admin帳號的私鑰
29. 調整其中的gateway設定檔：修改peer orderer ca節點ip、Admin0帳號的私鑰
28. 啟動所有api服務
```sh
cd ~/go/src/數字資產/digital-assets-node-api

# 查找IP
docker network inspect digital-assets_bcnet 
# 查找Admin0帳號的私鑰
cd ~/go/src/數字資產/digital-assets-network
cd organizations/
根據gateway設定檔內的路徑查找

# 把上面查詢資訊寫進去
vim gateway/org1-Network.yaml
vim gateway/org2-Network.yaml

# 重返digital-assets-node-api專案
cd ~/go/src/數字資產/digital-assets-node-api
docker-compose up -d
```

以上，完整啟動。

可使用digital-assets-node-api/jmeter-test進行測試







