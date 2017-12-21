#!/bin/bash
set -x
# Make sure dump file exist
DUMP_FILE=$1
if [ ! -e "$DUMP_FILE" ];then
    echo "-> please provide an exiting dump file"
    exit 0
fi

## Get db container
ID=$(docker ps -q --filter "label=com.docker.swarm.service.name=kernelci_mongo" 2>/dev/null)
if [ "$ID" = "" ];then
  echo "-> cannot found container for service kernelci_mongo"
  exit 0
fi

## Copy dump to container
DUMP_FOLDER=$(tar xvf $DUMP_FILE | head -n 1)
docker cp $DUMP_FOLDER $ID:/tmp
rm -r ./$DUMP_FOLDER

## Restore dump
docker exec $ID /bin/bash -c "mongorestore -d kernel-ci /tmp/$DUMP_FOLDER "
