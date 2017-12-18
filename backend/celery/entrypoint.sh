#!/bin/bash

# TOREMOVE
# ugly fix to change "localhost" into "redis" for communication between service
# will be done through env / secret later on
sed -i '' -e s/localhost/redis/ /home/user/kernelci-backend/app/taskqueue/celeryconfig.py

# Run celery worker
cd /home/user/kernelci-backend/app
celery worker -Ofair --autoscale=3,1 --app=taskqueue --broker=redis://redis:6379/0 -E
