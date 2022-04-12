#!/bin/bash

# 
# 組織向通道提交鏈碼，只須一個組織做一次
# 
# 參數：功能選擇, 通道名稱, 第幾個組織（從1開始）, 第幾個peer（從0開始）, peer port號（從7051開始）, 合約名稱（external-chaincode/<合約名稱>）, 合約版本（1.0.0）, 合約序號（從1開始）, POLICY
# 


# org1提交該鏈碼給通道
docker exec cli scripts/deploycc-3nd-cmd.sh commitchaincode ngmtsyschannel 1 0 7051 orderform 1.0.0 1 "OR('Org1MSP.member','Org2MSP.member')"

# org2提交該鏈碼給通道
# docker exec cli scripts/deploycc-3nd-cmd.sh commitchaincode ngmtsyschannel 2 0 9051 orderform 1.0.0 1 "AND('Org1MSP.member','Org2MSP.member')"


# ==================================================================================================

# 檢查該鏈碼是否可提交
# docker exec cli scripts/deploycc-3nd-cmd.sh querycommitchaincode ngmtsyschannel 1 0 7051 orderform 1.0.0 1 "AND('Org1MSP.member','Org2MSP.member')"

# 檢查該鏈碼是否可提交
docker exec cli scripts/deploycc-3nd-cmd.sh querycommitchaincode ngmtsyschannel 2 0 9051 orderform 1.0.0 1 "OR('Org1MSP.member','Org2MSP.member')"

# ==================================================================================================

