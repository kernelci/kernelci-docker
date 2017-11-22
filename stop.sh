#!/bin/bash

# Start the whole application
echo "-> Stopping the application..."

# Remove the stack
docker stack rm kernelci
sleep 15
echo "-> stack removed"

# Remove the network (if needed)
docker newtwork rm kernelci_default 2>/dev/null
echo "-> network removed"

# Remove configs
docker config rm frontend database 2>/dev/null
echo "-> configs removed"

