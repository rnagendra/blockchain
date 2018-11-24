#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -ev

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

docker-compose -f docker-compose.yml down

docker-compose -f docker-compose.yml up -d ca.tbfc.com orderer.tbfc.com peer0.buyer.tbfc.com peer0.seller.tbfc.com peer0.bank.tbfc.com couchdb

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export TBFC_START_TIMEOUT=<larger number>
export TBFC_START_TIMEOUT=10
#echo ${TBFC_START_TIMEOUT}
sleep ${TBFC_START_TIMEOUT}

# Create the Buyer channel
docker exec -e "CORE_PEER_LOCALMSPID=BuyerMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@buyer.tbfc.com/msp" peer0.buyer.tbfc.com peer channel create -o orderer.tbfc.com:7050 -c mychannel -f /etc/hyperledger/configtx/channel.tx
# Join peer0.buyer.tbfc.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=BuyerMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@buyer.tbfc.com/msp" peer0.buyer.tbfc.com peer channel join -b mychannel.block


# Create the Seller channel
docker exec -e "CORE_PEER_LOCALMSPID=SellerMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@seller.tbfc.com/msp" peer0.seller.tbfc.com peer channel create -o orderer.tbfc.com:7050 -c mychannel -f /etc/hyperledger/configtx/channel.tx
# Join peer0.seller.tbfc.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=SellerMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@seller.tbfc.com/msp" peer0.seller.tbfc.com peer channel join -b mychannel.block


# Create the Bank channel
docker exec -e "CORE_PEER_LOCALMSPID=BankMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@bank.tbfc.com/msp" peer0.bank.tbfc.com peer channel create -o orderer.tbfc.com:7050 -c mychannel -f /etc/hyperledger/configtx/channel.tx
# Join peer0.seller.tbfc.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=BankMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@bank.tbfc.com/msp" peer0.bank.tbfc.com peer channel join -b mychannel.block
