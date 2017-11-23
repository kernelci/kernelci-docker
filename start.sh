#!/bin/bash

STACK_NAME="kernelci"

# Make sure Docker daemon is in swarm mode
NODES=$(docker node ls 2>/dev/null)
if [ $? = 1 ]; then
    echo "Docker daemon must run in swarm mode"
    echo "-> run the \"docker swarm init\" command to enable swarm mode"
    exit 1
fi

# Make sure stack is not already running
docker stack ps $STACK_NAME 2>/dev/null
if [ $? = 0 ]; then
    echo "Application is already running"
    exit 0
fi

# Get IP of Docker host from the DOCKER_HOST environment variable
IP=$(echo $DOCKER_HOST | cut -d'/' -f3 | cut -d':' -f1)
if [ "$IP" = "" ]; then
  IP="127.0.0.1"
fi

# Generate admin token in the uuid (Universal Unique Identifier) format
# ex: efad9089-c8a3-455d-881f-5f05a44a5349
UUID=$(docker container run --rm lucj/uuid:1.0 2>/dev/null)
echo "-> token generated: $UUID"

# Create / update config for frontend initialisation
echo "-> Creating frontend configuration"
docker config rm frontend 1>/dev/null 2>&1
sed "s/API_TOKEN/$UUID/" frontend/flask_settings > config/frontend.config
docker config create frontend config/frontend.config 1>/dev/null

# Set or update token
echo "-> Create / update database token"
docker volume create data
docker container run -d -v data:/data/db --name mongo mongo:3.4
sleep 15 # Wait for mongo to be ready
docker container exec $(docker ps -q -f name=mongo) mongo kernel-ci --eval 'db["api-token"].update({ "username" : "admin"}, { "username" : "admin", "properties" : [ 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0 ], "token" : "'$UUID'", "version" : "1.0", "email" : "admin@kernelci.org", "expired" : false, "expires_on" : null}, {upsert: true})'
docker container rm -f mongo

# Start the whole application
echo "-> Starting the application"
docker stack deploy -c docker-compose.yml $STACK_NAME

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
