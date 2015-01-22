#!/bin/bash

environment=$(test -z "$2" && echo "production" || echo "$2")
app_root_path=$(cat ./tmp/app_root_path)
callback_path=$(cat ./tmp/callbacks_path)
watchdog_pid_file=${app_root_path}/tmp/pids/nohup.pid

case "$1" in
    start)
        # not generate pid file when first start
        # cannot use `ps -p $(cat ${watchdog_pid_file})`
        if [[ $(ps -ef | grep "watch_dog.sh" | grep -v "grep" | wc -l) -eq 0 ]];
        then
            nohup /bin/sh ${app_root_path}/lib/script/watch_dog.sh ${environment} ${app_root_path} ${callback_path} >> log/nohup.log 2>&1 &
            echo -e "\t nohup start $(test $? -eq 0 && echo "successfully" || echo "failed")."
            echo $! > ${watchdog_pid_file}
            test -f nohup.out && rm nohup.out
        else
            echo -e "\t nohup start failed - process is already running."
        fi
        ;;
    stop)
        watchdog_pid=$(cat ${watchdog_pid_file})
        ps -p ${watchdog_pid} > /dev/null
        if [[ $? -eq 0 ]];
        then
            kill -kill ${watchdog_pid}
            echo -e "\t nohup stop $(test $? -eq 0 && echo "successfully" || echo "failed")."
        else
            echo -e "\t nohup stop failed - process not exist."
        fi
        ;;
    status)
        # ps result menu
        ps -ef | grep "pid" | grep -v "grep"
        # ps result list
        ps -ef | grep "nohup.sh" | grep -v "grep"
        ps -ef | grep "watch_dog.sh" | grep -v "grep"
        ps -ef | grep "rake:agent:main" | grep -v "grep"

        test -f ${app_root_path}/tmp/crontab.wait && echo -e "\twait" || echo -e "\tactive"
        ;;
    active)
        cd ${app_root_path} && rm tmp/crontab.wait
        ;;
    wait)
        cd ${app_root_path} && touch tmp/crontab.wait
        ;;
    *)
        echo "usage ./nohup.sh {start|stop|status|active|wait}"
        ;;
esac
