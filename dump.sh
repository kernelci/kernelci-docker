#!/bin/sh

# Dump timestamp
ts=$(date -u "+%Y%m%dT%H%M%S")

# Local dump folder
DUMP_FOLDER="/tmp"

## Backup DB

# Name of the database to dump
DB="kernel-ci"

# Get db container
db=$(docker ps | grep mongo | awk '{print $1}')

# Dump database
docker exec $db mongodump -d $DB --archive=/tmp/kernelci-$ts.gz --gzip

# Save on host (/var/lib/kernelci/dump)
docker cp $db:/tmp/kernelci-$ts.gz ${DUMP_FOLDER:-/tmp}

## Backup logs

# Run alpine container using logs volume
docker run \
  --rm \
  -v kernelci_kci:/tmp/logs \
  -v ${DUMP_FOLDER:-/tmp}:/tmp/dump \
  alpine tar -zcvf /tmp/dump/kernelci-logs-$ts.gz /tmp/logs
