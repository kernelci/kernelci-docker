#!/bin/bash

echo "-> Stopping the application..."

echo "-> removing stack"
docker stack rm kernelci

echo "-> wait for all the services to stop gracefully"
sleep 15

echo "-> make sure dedicated network was removed"
docker network rm kernelci_default 2>/dev/null

echo "-> Application have been stopped"
