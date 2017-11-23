#!/bin/bash

echo "-> Stopping the application..."

echo "-> removing stack"
docker stack rm kernelci

echo "-> wait for all the services to stop gracefully"
sleep 15

echo "-> removing dedicated network"
docker network rm kernelci_default

echo "-> removing frontend config"
docker config rm frontend

echo "-> Application have been stopped"
