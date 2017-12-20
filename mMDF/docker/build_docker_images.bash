#!/bin/bash
#
# this script build the docker images that are needed to run mdf locally
# 
# by: Max Novelli
#     man8@pitt.edu
#     2017/11/28
#

#
# constants
MONGODB_TAG="rnel_mongodb:1.0"
POSTGRESQL_TAG="rnel_postgresql:1.0"

#
# check if we are sudoers
echo "Checking if this user is a sudoer..."
sudo ifconfig 1>/dev/null 2>&1
res=$?
if [ ${res} -ne 0 ]; then
  echo " - Error. This user is not a sudoer. Please check permissions. Exiting"
  exit 1
fi
echo "...done. Good to go."

#
# build images
# mongodb
echo "cd-ing in mongodb folder..."
cd mongodb
echo "...done"
echo "Building mongodb image..."
echo "cmd =>sudo docker build . -f mongodb/Dockerfile.mongodb -t ${MONGODB_TAG}<="
sudo docker build . -f Dockerfile.mongodb -t ${MONGODB_TAG} 
echo "...done"
#
# postgresql
echo "cd-ing in postgresql folder..."
cd ../postgresql
echo "...done"
echo "Building postgresql image..."
echo "cmd =>sudo docker build . -f postgresql/Dockerfile.postgresql -t ${POSTGRESQL_TAG}<="
sudo docker build . -f Dockerfile.postgresql -t ${POSTGRESQL_TAG}
echo "...done"

