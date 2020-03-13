#!/bin/bash

if [ "$1" != "-y" ];then
    while true; do
        read -p "CAUTION: This is a destructive script that will destroy all kernel-ci docker data. Proceed ? " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) echo "Nothing done";exit;;
            * ) echo "Please answer yes(y/Y) or no(n/N).";;
        esac
    done
fi
echo "-> Remove volume..."
docker volume rm kernelci_data
docker volume rm kernelci_kci
