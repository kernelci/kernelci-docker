#!/bin/bash
set -x
# Make sure dump file exist
DUMP_FILE=$1
if [ ! -e "$DUMP_FILE" ];then
    echo "-> please provide an exiting dump file"
    exit 1
fi

## Get db container
ID=$(docker ps -q --filter "label=com.docker.swarm.service.name=kernelci_mongo" 2>/dev/null)
if [ "$ID" = "" ];then
  echo "--Container for service kernelci_mongo not found exiting--"
  exit 1
fi

## Copy dump to container
tar xvf $DUMP_FILE
if [ $? -eq 0 ];then
  echo "--Databse backup extracted correctly--"
else
  echo "--Something went wrong wile extracting the database from $DUMP_FILE--"
  exit 1
fi
DUMP_FOLDER=$(sed -e 's/.tar.gz//' <<<$DUMP_FILE)
docker cp $DUMP_FOLDER $ID:/tmp
rm -r ./$DUMP_FOLDER

## Restore dump
docker exec $ID /bin/bash -c "mongorestore --db=kernel-ci /tmp/$DUMP_FOLDER/kernel-ci"
exit 0
