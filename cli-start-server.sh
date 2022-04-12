#!/bin/bash

docker-compose -f ./docker/docker-compose-cli.yaml up -d 2>&1

docker ps -a

if [ $? -ne 0 ]; then
    echo $?echo "ERROR !!!! 無法啟動cli console..."
    exit 1
fi

# docker-compose -f ./docker/docker-compose-cli.yaml down

