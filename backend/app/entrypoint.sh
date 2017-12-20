#!/bin/bash

#TEMPORARY: fix to change "localhost" into "redis" for communication between service
sed -i '' -e s/localhost/redis/ /srv/kernelci-backend/app/taskqueue/celeryconfig.py

#TEMPORARY: fix to set the storage url
sed -i '' -e s/STORAGE_URL/${STORAGE_URL}/ /etc/linaro/kernelci-backend.cfg

# Wait until mongo is up and running
echo "-> waiting for mongo to be available"
mongo --host mongo --eval "db.stats()"
while [[ $? != 0 ]]; do
  mongo --host mongo --eval "db.stats()"
done
echo "-> mongo is available, launching the backend"

# run backend application
python -OO -R /srv/kernelci-backend/app/server.py
