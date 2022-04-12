#!/bin/bash

# 
# 參數：功能選擇, 通道名稱, 第幾個組織（從1開始）, 第幾個peer（從0開始）, peer port號（從7051開始）
# 


# 建立channel block
docker exec cli scripts/createchannel-cmd.sh createchannel ngmtsyschannel 1 0 7051

# ====================================================================================================

# 將org1的peer0加入通道
docker exec cli scripts/createchannel-cmd.sh joinchannel ngmtsyschannel 1 0 7051

# 將org1的peer1加入通道
docker exec cli scripts/createchannel-cmd.sh joinchannel ngmtsyschannel 1 1 8051

# 將org2的peer0加入通道
docker exec cli scripts/createchannel-cmd.sh joinchannel ngmtsyschannel 2 0 9051

# 將org2的peer1加入通道
docker exec cli scripts/createchannel-cmd.sh joinchannel ngmtsyschannel 2 1 10051

# ====================================================================================================


# 將org1的peer0設定為anchor peer
docker exec cli scripts/createchannel-cmd.sh setanchorpeer ngmtsyschannel 1 0 7051

# 將org2的peer0設定為anchor peer
docker exec cli scripts/createchannel-cmd.sh setanchorpeer ngmtsyschannel 2 0 9051
