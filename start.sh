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
docker stack deploy -c docker-stack.yml $STACK_NAME
echo "-> application deployed"

## Wait for the application to be available

echo "-> waiting for backend..."
while [ $(curl -s -m 3 -o /dev/null -w "%{http_code}" $IP:8081) -ne 200 ]; do
   sleep 1
done
echo "-> waiting for frontend..."
while [ $(curl -s -m 3 -o /dev/null -w "%{http_code}" $IP:8080) -ne 200 ]; do
  sleep 1
done

## Configure the application

echo "-> configuring the application..."

### Get token from backend

echo "-> requesting token from backend..."
TOKEN=""
while [ "$TOKEN" = "" ];do
  TOKEN=$(curl -m 3 -s -X POST -H "Content-Type: application/json" -H "Authorization: MASTER_KEY" -d '{"email": "adm@kernelci.org", "admin": 1}' $IP:8081/token | docker container run --rm -i lucj/jq -r .result[0].token 2>/dev/null)
  sleep 1
done
echo $TOKEN > .kernelci_token
echo "-> token returned: $TOKEN"

### Create configuration with token created

CONFIG=frontend-$(date "+%Y%m%dT%H%M%S")
# sed "s/API_TOKEN/$TOKEN/" frontend/flask_settings-TPL > config/frontend.config
sed -e "s/^BACKEND_TOKEN.*$/BACKEND_TOKEN = \"$TOKEN\"/" frontend/flask_settings > config/frontend.config
docker config create $CONFIG config/frontend.config

### Update frontend with configuration

docker service update --config-add src=$CONFIG,target=/etc/linaro/kernelci-frontend.cfg kernelci_frontend

echo "-> application configured"
echo "--> backend available on http://${IP}:8081"
echo "--> frontend available on http://${IP}:8080"
