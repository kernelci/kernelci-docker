#!/bin/bash

# Wait until redis is up and running
echo "-> waiting for redis to be available"
redis-cli -h redis echo "alive" 2>/dev/null
while [[ $? != 0 ]]; do
  redis-cli -h redis echo "alive" 2>/dev/null
done
echo "-> redis is available, launching the frontend"

# run uwsgi server
uwsgi --ini /srv/uwsgi.ini
