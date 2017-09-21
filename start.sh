#!/bin/bash

# Note: temporary script to ease the start process by providing backend token to frontend

# Build all the images (if not present locally)
echo "### Building the images"
echo
docker-compose build

# Start the whole application
echo "### Start the application"
echo
docker-compose up -d

# Wait for the app to be ready
# TODO: check on /version endpoint until it's available
sleep 15 

# Get token from API
echo "### Generate API token"
token=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: MASTER_KEY" -d '{"email": "me@gmail.com", "admin": 1}' localhost:8081/token | jq -r ".result[0].token")
echo "token is $token"
echo

# Provide token to frontend
echo "### Provide token to frontend"
cp frontend/flask_settings.bak frontend/flask_settings 2>/dev/null
sed -i .bak "s/TO_REPLACE_WITH_TOKEN_GENERATED_FROM_API/$token/" frontend/flask_settings

# Restart frontend so it take into account new token
echo "### Restart frontend"
echo
docker-compose stop frontend
docker-compose start frontend

echo "### You'r good to go, frontend is available on http://localhost:8080"
echo
