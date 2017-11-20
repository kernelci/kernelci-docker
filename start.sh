#!/bin/bash

# Make sure Docker daemon is in swarm mode
docker node ls 1>/dev/null 2>&1
if [ $? = 1 ]; then
    echo "Docker daemon must run in swarm mode"
    echo "-> run the \"docker swarm init\" command to enable swarm mode"
    exit 1
fi

# Get IP of Docker host
IP=$(echo $DOCKER_HOST | cut -d'/' -f3 | cut -d':' -f1)

# Generate admin token in the uuid (Universal Unique Identifier) format
# ex: efad9089-c8a3-455d-881f-5f05a44a5349
UUID=$(docker container run --rm lucj/uuid:1.0)

# Cleanup previous configs
docker config rm frontend database 2>/dev/null

# Create config for mongo initialisation
sed "s/API_TOKEN/$UUID/" config/database.template > config/database.config
docker config create database config/database.config

# Create config for frontend initialisation
sed "s/API_TOKEN/$UUID/" frontend/flask_settings > config/frontend.config
docker config create frontend config/frontend.config

# Start the whole application
echo "-> Starting the application..."
docker stack deploy -c stack.yml kernelci

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
echo "-> application is deployed:"
echo "- frontend available on http://${IP}:8080"
echo "- backend  available on http://${IP}:8081"
echo
