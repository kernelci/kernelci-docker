#!/bin/bash

# Make sure Docker daemon is in swarm mode
docker node ls 1>/dev/null 2>&1
if [ $? = 1 ]; then
    echo "Docker daemon must run in swarm mode"
    echo "-> run the \"docker swarm init\" command to enable swarm mode"
    exit 1
fi

# Get IP of Docker host from the DOCKER_HOST environment variable
IP=$(echo $DOCKER_HOST | cut -d'/' -f3 | cut -d':' -f1)
if [ "$IP" = "" ]; then
  IP="127.0.0.1"
fi

# Generate admin token in the uuid (Universal Unique Identifier) format
# ex: efad9089-c8a3-455d-881f-5f05a44a5349
UUID=$(docker container run --rm lucj/uuid:1.0 2>/dev/null)

# Cleanup previous configs
docker config rm frontend database 2>/dev/null

# Create config for mongo initialisation
echo "-> Creating database configuration"
sleep 2
sed "s/API_TOKEN/$UUID/" config/database.template > config/database.config
docker config create database config/database.config 1>/dev/null

# Create config for frontend initialisation
echo "-> Creating frontend configuration"
sleep 2
sed "s/API_TOKEN/$UUID/" frontend/flask_settings > config/frontend.config
docker config create frontend config/frontend.config 1>/dev/null

# Start the whole application
echo "-> Starting the application"
docker stack deploy -c stack.yml kernelci 1>/dev/null

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
