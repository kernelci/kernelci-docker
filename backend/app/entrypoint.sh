#!/bin/bash

# TOREMOVE
# ugly fix to change "localhost" into "redis" for communication between service
# will be done through env / secret later on
sed -i '' -e s/localhost/redis/ /srv/kernelci-backend/app/taskqueue/celeryconfig.py

# Wait until mongo is up and running
echo "-> waiting for mongo to be available"
mongo --host mongo --eval "db.stats()"
while [[ $? != 0 ]]; do
  mongo --host mongo --eval "db.stats()"
done
echo "-> mongo is available, launching the backend"

# run backend application
python -OO -R /srv/kernelci-backend/app/server.py
