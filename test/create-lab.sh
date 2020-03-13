#!/bin/sh
TOKEN=$1
SERVER="127.0.0.1"
LAB_NAME="lab-baylibre-$(date "+%Y%m%dT%H%M%S")"
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: $TOKEN" -d '{"version": "1.0", "name": "'${LAB_NAME}'", "contact": {"name": "Hilman", "surname": "Kevin", "email": "khilman@baylibre.com"}}' $SERVER:8081/lab
