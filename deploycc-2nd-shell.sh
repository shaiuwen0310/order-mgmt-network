#!/bin/bash

# 
# 參數：功能選擇, 通道名稱, 第幾個組織（從1開始）, 第幾個peer（從0開始）, peer port號（從7051開始）, 合約名稱（external-chaincode/<合約名稱>）, 合約版本（1.0.0）, PACKAGE_ID, 合約序號（從1開始）, POLICY
# 
# 一個組織只需要同意一次
# 


# org1同意該鏈碼執行
docker exec cli scripts/deploycc-2nd-cmd.sh approvechaincode ngmtsyschannel 1 0 7051 orderform 1.0.0 orderform_1.0.0:ace9480510ac64b8d304e0bcb27bdfcc871cd48f234953288257cece9dcdaf9f 1 "OR('Org1MSP.member','Org2MSP.member')"

# org2同意該鏈碼執行
docker exec cli scripts/deploycc-2nd-cmd.sh approvechaincode ngmtsyschannel 2 0 9051 orderform 1.0.0 orderform_1.0.0:ace9480510ac64b8d304e0bcb27bdfcc871cd48f234953288257cece9dcdaf9f 1 "OR('Org1MSP.member','Org2MSP.member')"


# ==================================================================================================

# 檢查該鏈碼是否可提交
docker exec cli scripts/deploycc-2nd-cmd.sh checkapprovechaincode ngmtsyschannel 1 0 7051 orderform 1.0.0 "" 1 "OR('Org1MSP.member','Org2MSP.member')"

# 檢查該鏈碼是否可提交
docker exec cli scripts/deploycc-2nd-cmd.sh checkapprovechaincode ngmtsyschannel 2 0 9051 orderform 1.0.0 "" 1 "OR('Org1MSP.member','Org2MSP.member')"

# ==================================================================================================

