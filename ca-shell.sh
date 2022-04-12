#!/bin/bash

. ca-cmd.sh

# org0（org0一律為orderer組織）, org0 CA's port
enrollCA 0 7054

# org1（peer組織從org1開始）, org1 CA's port
enrollCA 1 8054

# org2, org2 CA's port
enrollCA 2 9054

##########################

# 選擇org1, org1中第1個peer（從0開始數）, org1 CA's port
regdEnrollPeer 1 0 8054

# 選擇org1, org1中第2個peer, org1 CA's port
regdEnrollPeer 1 1 8054

# 選擇org2, org2中第1個peer, org2 CA's port
regdEnrollPeer 2 0 9054

# 選擇org2, org2中第2個peer, org2 CA's port
regdEnrollPeer 2 1 9054

##########################

# 選擇org1, org1中第1個user（從0開始數）, org1 CA's port
regdEnrollUser 1 0 8054

# 選擇org1, org1中第2個user（從0開始數）, org1 CA's port
regdEnrollUser 1 1 8054

# 選擇org2, org2中第1個user, org2 CA's port
regdEnrollUser 2 0 9054

# 選擇org2, org2中第2個user, org2 CA's port
regdEnrollUser 2 1 9054

##########################

# 選擇org0, org0中第1個admin（從0開始數）, org0 CA's port
regdEnrollAdmin 0 0 7054

# 選擇org0, org0中第2個admin（從0開始數）, org0 CA's port
regdEnrollAdmin 0 1 7054

# 選擇org1, org1中第1個admin（從0開始數）, org1 CA's port
regdEnrollAdmin 1 0 8054

# 選擇org1, org1中第2個admin（從0開始數）, org1 CA's port
regdEnrollAdmin 1 1 8054

# 選擇org2, org2中第1個admin（從0開始數）, org2 CA's port
regdEnrollAdmin 2 0 9054

# 選擇org2, org2中第2個admin（從0開始數）, org2 CA's port
regdEnrollAdmin 2 1 9054

##########################

# 選擇org0, org0中第1個orderer（從0開始數）, org0 CA's port
regdEnrollOrderer 0 0 7054

# 選擇org0, org0中第2個orderer（從0開始數）, org0 CA's port
regdEnrollOrderer 0 1 7054

# 選擇org0, org0中第3個orderer（從0開始數）, org0 CA's port
regdEnrollOrderer 0 2 7054

# 選擇org0, org0中第4個orderer（從0開始數）, org0 CA's port
regdEnrollOrderer 0 3 7054

# 選擇org0, org0中第5個orderer（從0開始數）, org0 CA's port
regdEnrollOrderer 0 4 7054