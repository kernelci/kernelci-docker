#!/bin/bash

while getopts "d:l:" option
do
    case $option in
        d) DB_DUMP_FILE=$OPTARG;;
        l) LOG_DUMP_FILE=$OPTARG;;
    esac
done

if [ ! "$DB_DUMP_FILE" ] && [ ! "$LOG_DUMP_FILE" ];then
    echo "Usage: ./seed.sh -d DATABASE_BACKUP.tar.gz -l LOG_BACKUP.tar.gz"
fi

if [ ! -z "$DB_DUMP_FILE" ];then
    echo "-->Restoring Mongo database from $DB_DUMP_FILE"
    ## Get db container
    ID=$(docker ps -q --filter "label=com.docker.swarm.service.name=kernelci_mongo" 2>/dev/null)
    if [ "$ID" = "" ];then
      echo "--Container for service kernelci_mongo not found exiting--"
      exit 1
    fi

    ## Copy dump to container
    tar xvf $DB_DUMP_FILE
    if [ $? -eq 0 ];then
      echo "--Database backup extracted correctly--"
    else
      echo "--Something went wrong wile extracting the database from $DB_DUMP_FILE--"
      exit 1
    fi
    DUMP_FOLDER=$(sed -e 's/.tar.gz//' <<<$DB_DUMP_FILE)
    docker cp $DUMP_FOLDER $ID:/tmp
    rm -r ./$DUMP_FOLDER

    ## Restore dump
    docker exec $ID /bin/bash -c "mongorestore --db=kernel-ci /tmp/$DUMP_FOLDER/kernel-ci"
fi

if [ ! -z "$LOG_DUMP_FILE" ];then
    echo "-->Restoring logs database from $LOG_DUMP_FILE"
    ## Restore logs
    tar xvf $LOG_DUMP_FILE
    docker run --rm -v `pwd`/kernel-ci/:/tmp/kernelci_logs/ -v kernelci_kci:/var/lib/docker/volumes/kernelci_kci/_data busybox cp -r /tmp/kernelci_logs/. /var/lib/docker/volumes/kernelci_kci/_data
    rm -r kernel-ci/
fi

exit 0
