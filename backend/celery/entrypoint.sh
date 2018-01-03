#!/bin/bash

#TEMPORARY: fix to change "localhost" into "redis" for communication between service
sed -i '' -e s/localhost/redis/ /home/user/kernelci-backend/app/taskqueue/celeryconfig.py

#TEMPORARY: fix to set the storage url
sed -i '' -e "s@STORAGE_URL@$STORAGE_URL@" /etc/linaro/kernelci-celery.cfg

# Run celery worker
cd /home/user/kernelci-backend/app
celery worker -Ofair --autoscale=3,1 --app=taskqueue --broker=redis://redis:6379/0 -E
