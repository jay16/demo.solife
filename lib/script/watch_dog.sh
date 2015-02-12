#!/bin/bash

ENVIRONMENT=$1
APP_ROOT_PATH=$2
CALLBACK_PATH=$3
CHANGE_LOG_PATH=$4

# stop process id
echo $$ > ${APP_ROOT_PATH}/tmp/pids/watch_dog.pid
while true
do
    # check callbacks every 5 seconds
    if [[ $(ls ${CALLBACK_PATH} | wc -l) -eq 0 ]];
    then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): idleness."
    else
        /bin/bash -l -c "cd ${APP_ROOT_PATH} && RACK_ENV=${ENVIRONMENT} bundle exec rake callback:main >> ./log/rake.log 2>&1"
    fi

    # check change_logs every day 09:00
    hour=$(date '+%H')
    minute=$(date '+%M')
    second=$(date '+%S')
    if [[ $((10#$hour%12))   -eq 10  && 
          $((10#$minute%60)) -gt 10 && 
          $((10#$second%60)) -lt 5  &&
          $(ls ${CHANGE_LOG_PATH} | wc -l) -gt 0 ]];
    then
        /bin/bash -l -c "cd ${APP_ROOT_PATH} && RACK_ENV=${ENVIRONMENT} bundle exec rake weixin:sendall >> ./log/weixin_sendall.log 2>&1"
    fi

    sleep 5
done
