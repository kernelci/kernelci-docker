#!/bin/bash

echo "-> Stopping the application..."

docker-compose down

echo "-> make sure dedicated network was removed"
docker network rm kernelci_default 2>/dev/null

echo "-> Application have been stopped"
