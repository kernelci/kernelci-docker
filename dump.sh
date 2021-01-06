#!/bin/sh

while getopts "d:" option
do
    case $option in
        d)
	# remove trailing slash
	DUMP_FOLDER=$(echo $OPTARG | sed 's,/*$,,')
	echo "INFO: dump in $DUMP_FOLTER"
	;;
    esac
done

# Dump timestamp
ts=$(date -u "+%Y%m%dT%H%M%S")

## Backup DB

# Name of the database to dump
DB="kernel-ci"

# Get db container
db=$(docker ps | grep mongo | awk '{print $1}')

if [ "$db" = "" ];then
  echo "No mongo container running => exiting"
  exit 1
fi

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
  alpine tar -zcvf /tmp/dump/kernelci-logs-$ts.tar.gz /tmp/logs

echo
echo "=> database and log files will be saved in folder ${DUMP_FOLDER:-/tmp}"
echo

