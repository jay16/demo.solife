#!/bin/sh  
# 
PORT=$(test -z "$2" && echo "4000" || echo "$2")
ENVIRONMENT=$(test -z "$3" && echo "production" || echo "$3")

UNICORN=unicorn  
CONFIG_FILE=config/unicorn.rb  
 
APP_ROOT_PATH=$(pwd)
# user bash environment for crontab job.
shell_used=${SHELL##*/}
echo "** shell used: ${shell_used}"
test -f ~/.${shell_used}_profile && source ~/.${shell_used}_profile > /dev/null 2>1&
test -f ~/.${shell_used}rc && source ~/.${shell_used}rc > /dev/null 2>1&
export LANG=zh_CN.UTF-8
cd ${APP_ROOT_PATH}
# use the current .ruby-version's command
bundle_command=$(rbenv which bundle)
gem_command=$(rbenv which gem)
case "$1" in      
    gem)
        shift 1
        $gem_commnd $@
    ;;
    precompile)
        RAILS_ENV=production $bundle_command exec rake assets:clean
        RAILS_ENV=production $bundle_command exec rake assets:my_precompile
    ;;
    bundle)
        echo "## bundle install"
        $bundle_command install --local > /dev/null 2>&1 
        if test $? -eq 0 
        then
          echo -e "\t bundle install --local successfully."
        else
          $bundle_command install
        fi
    ;;
    start)  
        test -d log || mkdir log
        test -d tmp || mkdir -p tmp/pids
        test -d public/callbacks || mkdir -p public/callbacks
        test -d public/change_logs || mkdir -p public/change_logs

        echo  "## compile phantom's C codes"
        cd ${APP_ROOT_PATH}
        cd lib/utils/processPattern
        gcc buildPatternHeader.c -o buildPatternHeader > /dev/null 2>&1
        echo -e "\t compile header $(test $? -eq 0 && echo "successfully" || echo "failed")."
        ./buildPatternHeader
        gcc processPattern.c -o processPattern > /dev/null 2>&1
        echo -e "\t compile pattern $(test $? -eq 0 && echo "successfully" || echo "failed")."
        # back to app_root_path
        cd ${APP_ROOT_PATH}

        echo "## start unicorn"
        echo -e "\t port: ${PORT} \n\t environment: ${ENVIRONMENT}"
        $bundle_command exec ${UNICORN} -c ${CONFIG_FILE} -p ${PORT} -E ${ENVIRONMENT} -D > /dev/null 2>&1
        echo -e "\t unicorn start $(test $? -eq 0 && echo "successfully" || echo "failed")."

        echo "## start nohup"
        /bin/sh nohup.sh start
        ;;  
    stop)  
        echo "## stop unicorn"
        kill -QUIT `cat tmp/pids/unicorn.pid`  
        echo -e "\t unicorn stop $(test $? -eq 0 && echo "successfully" || echo "failed")."

        echo "## stop nohup"
        /bin/sh nohup.sh stop
        ;;  
    restart|force-reload)  
        #kill -USR2 `cat tmp/pids/unicorn.pid`  
        sh unicorn.sh stop
        echo -e "\n\n-----------command sparate line----------\n\n"
        sh unicorn.sh start
        ;;  
    deploy)
        # ./unicorn.sh deploy | xargs -I cmd /bin/sh -c cmd
        # ./unicorn.sh deploy | sh
        echo "RACK_ENV=production bundle exec rake remote:deploy"
        ;;
    weixin_group_message)
        $bundle_command exec rake weixin:send_group_message
        ;;
    *)  
        echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload|deploy}" >&2  
        exit 3  
        ;;  
esac  
