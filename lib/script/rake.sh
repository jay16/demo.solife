#!/bin/bash

APP_ROOT_PATH=$1
ENVIRONMENT=$2

/bin/bash -l -c "cd ${APP_ROOT_PATH} && RACK_ENV=${ENVIRONMENT} bundle exec rake callback:main >> ./log/rake.log 2>&1"
