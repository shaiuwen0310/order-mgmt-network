#!/bin/bash

. genfile-cmd.sh

# 建立初始區塊
createGenesisBlock

# configtx.yaml中要執行的段落名稱, 要建立的帳本名稱（通道名稱不可大寫）
createChannelTx TwoOrgsChannel ngmtsyschannel
