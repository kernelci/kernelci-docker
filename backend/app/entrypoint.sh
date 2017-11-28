#!/bin/bash

# Wait until mongo is up and running
echo "-> waiting for mongo to be available"
mongo --host mongo --eval "db.stats()"
while [[ $? != 0 ]]; do
  mongo --host mongo --eval "db.stats()"
done
echo "-> mongo is available, launching the backend"

# run backend application
python -OO -R server.py
