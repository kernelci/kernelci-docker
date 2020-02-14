#!/bin/bash

#TEMPORARY: fix to change "localhost" into "redis" for communication between service
sed -i '' -e s/localhost/redis/ /srv/kernelci-backend/app/taskqueue/celeryconfig.py

# Run celery worker
cd /srv/kernelci-backend/app
celery worker -Ofair --autoscale=3,1 --app=taskqueue --broker=redis://redis:6379/0 -E
