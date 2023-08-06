#!/bin/bash
# Check service state via HTTPS and curl

SERVER=$1
USERNAME=$2
PASSWORD=$3

ENDPOINT="https://${SERVER}"
 
# Pulls the login page and strips out the auth token
HTTP_CODE=`curl -sLm 5 -w "%{http_code}\n\n" -c /tmp/cookies_tmp.txt --silent 'https://SERVICE' -o /dev/null`

if [[ $HTTP_CODE -eq 200 ]]; then
  authToken=`curl -sLm 5 -w "%{http_code}\n\n" -c /tmp/cookies_tmp.txt --silent 'https://SERVICE' | grep 'authenticity_token' | cut -c 67-110`
  GET_STATUS=`curl -sLm 5 -w "%{http_code}\n\n" -b /tmp/cookies_tmp.txt --silent --data 'userName=USERNAME&password=PASSWORD' --data-urlencode authenticity_token=$authToken 'https://SERVICE/login' -o /dev/null`
  if [[ $GET_STATUS -eq 200 ]]; then
    CHECK="OK"
  fi
  rm /tmp/cookies_tmp.txt
else
  CHECK="Failed"
fi

if [[ "$CHECK" == "OK" ]]; then
   echo "SERVICE OK"
   exit 0
elif [[ "$CHECK" == "Failed" ]]; then
   echo "Service not working: ${SERVER}"
   exit 2
else
   echo "Check failed"
   exit 3
fi

