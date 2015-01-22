#!/bin/bash

ENVIRONMENT=$1
APP_ROOT_PATH=$2
CALLBACK_PATH=$3

# stop process id
echo $$ > ${APP_ROOT_PATH}/tmp/pids/watch_dog.pid
while true
do
    if [[ $(ls ${CALLBACK_PATH} | wc -l) -eq 0 ]];
    then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): idleness."
    else
        /bin/sh ${APP_ROOT_PATH}/lib/script/rake.sh ${APP_ROOT_PATH} ${ENVIRONMENT}
    fi

    sleep 5
done
