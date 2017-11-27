#!/bin/bash

STACK_NAME="kernelci"

## Prerequisites

# Make sure Docker daemon is in swarm mode
NODES=$(docker node ls 2>/dev/null)
if [ $? = 1 ]; then
    echo "Docker daemon must run in swarm mode"
    echo "-> run the \"docker swarm init\" command to enable swarm mode"
    exit 1
fi

# Get IP of Docker host from the DOCKER_HOST environment variable
IP=$(echo $DOCKER_HOST | cut -d'/' -f3 | cut -d':' -f1)

# 127.0.0.1 is assumed if $DOCKET_HOST is empty
if [ "$IP" = "" ]; then
  IP="127.0.0.1"
fi

## Deploy the application

echo "-> deploying the application..."
docker stack deploy -c docker-compose.yml $STACK_NAME
echo "-> application deployed"

## Configure the application

# Requesting admin token from the API
echo "-> configuring the application..."

# Wait for the backend to be available
TOKEN=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: MASTER_KEY" -d '{"email": "adm@kernelci.org", "admin": 1}' $IP:8081/token | docker container run --rm -i lucj/jq -r .result[0].token)
while [[ "$TOKEN" = "" ]];do
  TOKEN=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: MASTER_KEY" -d '{"email": "adm@kernelci.org", "admin": 1}' $IP:8081/token | docker container run --rm -i lucj/jq -r .result[0].token)
  sleep 1
done
echo "-> token generated: $TOKEN"

# Create config
CONFIG=frontend-$(date "+%Y%m%dT%H%M%S")
sed "s/API_TOKEN/$TOKEN/" frontend/flask_settings > config/frontend.config
docker config create $CONFIG config/frontend.config

# Update frontend with configuration
docker service update --config-add src=$CONFIG,target=/etc/linaro/kernelci-frontend.cfg kernelci_frontend

echo "-> application configured"

## Waiting for application to be available

echo "-> waiting for the application to be available..."

while [[ "$(curl -s -o /dev/null -I -w "%{http_code}" $IP:8081)" != "200" ]]; do
  sleep 1
done
echo "--> backend available on http://${IP}:8081"
while [[ "$(curl -s -o /dev/null -I -w "%{http_code}" $IP:8080)" != "200" ]]; do
  sleep 1
done
echo "--> frontend available on http://${IP}:8080"
