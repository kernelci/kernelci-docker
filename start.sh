#!/bin/bash

STACK_NAME="kernelci"

## Checking prerequisites

# Make sure Docker daemon is in swarm mode
NODES=$(docker node ls 2>/dev/null)
if [ $? = 1 ]; then
    echo "Docker daemon must run in swarm mode"
    echo "-> run the \"docker swarm init\" command to enable swarm mode"
    exit 1
fi

# Get IP of Docker host from the DOCKER_HOST environment variable
IP=$(echo $DOCKER_HOST | cut -d'/' -f3 | cut -d':' -f1)

# localhost is assumed if $DOCKET_HOST is empty
if [ "$IP" = "" ]; then
  IP="127.0.0.1"
fi

## Start the application

# Start the whole application as a Docker stack
echo "-> Starting the application"
docker stack deploy -c docker-compose.yml $STACK_NAME

## Configuration

# Requesting admin token from the API
TOKEN=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: MASTER_KEY" -d '{"email": "me@gmail.com", "admin": 1}' localhost:8081/token | cut -d'"' -f6)
echo "-> token generated: $TOKEN"

# Create config
CONFIG=frontend-$(date "+%Y%m%dT%H%M%S")
sed "s/API_TOKEN/$TOKEN/" frontend/flask_settings > config/frontend.config
docker config create $CONFIG config/frontend.config

# Update service with configuration
docker service update --config-add src=$CONFIG,target=/etc/linaro/kernelci-frontend.cfg kernelci_frontend

## Check application is running

# Wait for the app (frontend + backend) to be ready
spin='-\|/'
i=0
while [[ "$(curl -s -o /dev/null -I -w "%{http_code}" $IP:8080)" != "200" ]]; do
  i=$(( (i+1) %4 ))
  echo -ne "\r${spin:$i:1} waiting for frontend..."
  sleep 1
done
echo -e "\r-> frontend is healthly"
i=0
while [[ "$(curl -s -o /dev/null -I -w "%{http_code}" $IP:8081)" != "200" ]]; do
  i=$(( (i+1) %4 ))
  echo -ne "\r${spin:$i:1} waiting for backend..."
  sleep 1
done
echo -e "\r-> backend is healthly"

echo
echo "-> application deployed:"
echo "- frontend available on http://${IP}:8080"
echo "- backend  available on http://${IP}:8081"
echo
