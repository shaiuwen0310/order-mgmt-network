#!/bin/bash

# 
# 參數：功能選擇, 通道名稱, 第幾個組織（從1開始）, 第幾個peer（從0開始）, peer port號（從7051開始）, 合約名稱（external-chaincode/<合約名稱>）
# 
# 在所有peer上安裝鏈碼
# 


# 安裝鏈碼設定檔到org1的peer0上
docker exec cli scripts/deploycc-1nd-cmd.sh installchaincode ngmtsyschannel 1 0 7051 orderform

# 安裝鏈碼設定檔到org1的peer0上
docker exec cli scripts/deploycc-1nd-cmd.sh installchaincode ngmtsyschannel 1 1 8051 orderform

# 安裝鏈碼設定檔到org1的peer0上
docker exec cli scripts/deploycc-1nd-cmd.sh installchaincode ngmtsyschannel 2 0 9051 orderform

# 安裝鏈碼設定檔到org1的peer0上
docker exec cli scripts/deploycc-1nd-cmd.sh installchaincode ngmtsyschannel 2 1 10051 orderform

# ==================================================================================================

# 查詢org1的peer0上的鏈碼有哪些
# 這不是必要流程
docker exec cli scripts/deploycc-1nd-cmd.sh checkinstalledchaincode ngmtsyschannel 1 0 7051 ""

# ==================================================================================================


