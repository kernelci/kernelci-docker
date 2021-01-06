#!/bin/sh

while getopts "d:" option
do
    case $option in
        d)
	# remove trailing slash
	DUMP_FOLDER=$(echo $OPTARG | sed 's,/*$,,')
	echo "INFO: dump in $DUMP_FOLDER"
	echo "$DUMP_FOLDER" | grep -q '^/'
	if [ $? -ne 0 ];then
		echo "ERROR: dump folder should be given full path"
		exit 1
	fi
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

# sanity check if volume exists
if [ $(docker volume ls | awk '{print $2}' |grep _kci$ | wc -l) -ge 2 ];then
	echo "ERROR: too many kci dava volumes"
	exit 1
fi
VOLUMENAME=$(docker volume ls | awk '{print $2}' |grep _kci$)

echo "Dump $VOLUMENAME"
if [ -z "$VOLUMENAME" ];then
	echo "ERROR: no volume name found"
	exit 1
fi
# Run alpine container using logs volume
docker run \
  --rm \
  -v $VOLUMENAME:/tmp/logs \
  -v ${DUMP_FOLDER:-/tmp}:/tmp/dump \
  alpine tar -zcvf /tmp/dump/kernelci-logs-$ts.tar.gz /tmp/logs

echo
echo "=> database and log files will be saved in folder ${DUMP_FOLDER:-/tmp}"
echo

