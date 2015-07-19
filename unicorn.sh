#!/bin/bash  
PORT=$(test -z "$2" && echo "4000" || echo "$2")
ENVIRONMENT=$(test -z "$3" && echo "production" || echo "$3")

UNICORN=unicorn  
CONFIG_FILE=config/unicorn.rb   
APP_ROOT_PATH=$(pwd)

# user bash environment for crontab job.
shell_used=${SHELL##*/}
# crontab environment used *sh* on centos
if [[ "${shell_used}" == "sh" ]]; 
then 
	shell_used="bash"; 
fi
echo "## shell used: ${shell_used}"
[ -f ~/.${shell_used}_profile ] && source ~/.${shell_used}_profile &> /dev/null
[ -f ~/.${shell_used}rc ] && source ~/.${shell_used}rc &> /dev/null
export LANG=zh_CN.UTF-8

# put below config lines added to ~/.bashrc to make 
# sure *rbenv* work normally, 
#
# 	export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
# 	export RBENV_ROOT="$HOME/.rbenv"
# 	if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
#
# use the current .ruby-version's command
bundle_command=$(rbenv which bundle)
gem_command=$(rbenv which gem)

# make sure command execute in app root path
cd ${APP_ROOT_PATH}
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
        /bin/sh unicorn.sh bundle

        test -d log || mkdir log
        test -d tmp || mkdir -p tmp/pids
        test -d public/callbacks || mkdir -p public/callbacks
        test -d public/change_logs || mkdir -p public/change_logs

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
