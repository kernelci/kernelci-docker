#!/bin/sh

# Wait until frontend and backend are ready

#TODO
# echo "-> waiting for frontend..."
# while [ "$(uwsgi_curl -t 3 frontend:5000 | grep html)" = "" ]; do
#   echo "-> retry <-"
#   sleep 2
# done

echo "-> waiting for backend..."
while [ $(curl -m 3 -s -o /dev/null -w "%{http_code}" backend:8888/version) -ne 200 ]; do
  sleep 2
done

# run nginx server
echo "-> running proxy..."
nginx -g "daemon off;"
