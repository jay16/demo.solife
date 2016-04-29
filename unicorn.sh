#!/usr/bin/env bash
# Description: script jobs around unicorn/redis/sidekiq/mysql 
# Author: jay@16/02/03
# Usage: 
# ./unicorn.sh {config|start|stop|start_redis|stop_redis|restart|deploy|update_assets|import_data|copy_data}
#
unicorn_port=${2:-'4001'}
unicorn_env=${3:-'production'}
unicorn_config_file=config/unicorn.rb

unicorn_pid_file=tmp/pids/unicorn.pid
redis_pid_file=tmp/pids/redis.pid
sidekiq_pid_file=tmp/pids/sidekiq.pid
sidekiq_log_file=log/sidekiq.log

bundle_command=$(rbenv which bundle)
gem_command=$(rbenv which gem)

# user bash environment for crontab job.
# shell_used=${SHELL##*/}   
app_root_path=$(pwd)
shell_used='bash'
[[ $(uname -s) = Darwin ]] && shell_used='zsh'

[[ -f ~/.${shell_used}rc ]] && source ~/.${shell_used}rc &> /dev/null
[[ -f ~/.${shell_used}_profile ]] && source ~/.${shell_used}_profile &> /dev/null

# put below config lines added to ~/.bashrc to make 
# sure *rbenv* work normally, 
#
#   export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
#   export RBENV_ROOT="$HOME/.rbenv"
#   if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
#
# use the current .ruby-version's command

export LANG=zh_CN.UTF-8
cd "${app_root_path}" || exit 1
case "$1" in      
    gem)
        shift 1
        $gem_command "$@"
    ;;

    bundle)
        echo '## bundle install'
        $bundle_command install --local > /dev/null 2>&1 
        if [[ $? -eq 0 ]]; then
          echo -e '\t# bundle install --local successfully'
        else
          $bundle_command install
        fi
    ;;

    config)
        bash "$0" bundle

        mkdir -p {log,tmp/{rb,js,pids}} > /dev/null 2>&1

        if [[ ! -f config/redis.conf ]]; then
            RACK_ENV=production $bundle_command exec rake redis:generate_config
            echo -e "\tgenerate config/redis.conf $([[ $? -eq 0 ]] && echo "successfully" || echo "failed")"
        fi

    ;;

    start)
        echo "## shell used: ${shell_used}"
        bash "$0" config
        bash "$0" start_redis
        bash "$0" start_sidekiq

        echo "## start unicorn"
        if [[ -f $unicorn_pid_file ]]; then
            echo -e '\t unicorn already started'
            exit 0
        fi

        rm -f tmp/rb/*.rb > /dev/null 2>&1
        echo -e "\t# port: ${unicorn_port}, environment: ${unicorn_env}"
        command_text="$bundle_command exec unicorn -c ${unicorn_config_file} -p ${unicorn_port} -E ${unicorn_env} -D"
        echo -e "\t$ run ${command_text}"
        run_result=$($command_text)
        echo -e "\t# unicorn start $([[ $? -eq 0 ]] && echo "successfully" || echo "failed")(${run_result})"
        ;;

    stop)  
        echo '## stop unicorn'
        if [[ ! -f $unicorn_pid_file ]]; then
            echo -e '\t unicorn never started'
            exit 1
        fi

        cat $unicorn_pid_file | xargs -I pid kill -QUIT pid
        if [[ $? -eq 0 ]]; then
            rm -f $unicorn_pid_file
            echo -e '\t unicorn stop successfully'
        else
            echo -e '\t unicorn stop failed'
        fi
        ;;

    restart|force-reload)  
        #kill -USR2 `cat tmp/pids/unicorn.pid`  
        bash "$0" stop
        echo -e '\n\n#-----------command sparate line----------\n\n'
        bash "$0" start
        ;;

    start_redis)
        bash "$0" config

        echo '## start redis'
        if [[ -f $redis_pid_file ]]; then
            echo -e '\t redis already started'
            exit 0
        fi

        command_text='redis-server ./config/redis.conf'
        echo -e "\t$ run ${command_text}"
        run_result=$($command_text) #> /dev/null 2>&1
        echo -e "\t# redis start $([[ $? -eq 0 ]] && echo "successfully" || echo "failed")(${run_result})."
        ;;

    stop_redis)
        echo '## stop redis'

        if [[ ! -f $redis_pid_file ]]; then
            echo -e '\t redis never started'
            exit 1
        fi

        cat "$redis_pid_file" | xargs -I pid kill -QUIT pid
        if [[ $? -eq 0  ]]; then
            rm -f $redis_pid_file
            echo -e '\t redis stop successfully'
        else
            echo -e '\t redis stop failed'
        fi
        ;;

    start_sidekiq)
        bash "$0" config

        echo '## start sidekiq'
        if [[ -f $sidekiq_pid_file ]]; then
            echo -e '\t sidekiq already started'
            exit 0
        fi

        command_text="${bundle_command} exec sidekiq -r ./config/boot.rb -C ./config/sidekiq.yaml -e production -d"
        echo -e "\t$ run ${command_text}"
        run_result=$($command_text) #> /dev/null 2>&1
        echo -e "\t# sidekiq start $([[ $? -eq 0 ]] && echo "successfully" || echo "failed")(${run_result})."
        ;;

    *)  
        echo "Usage: $SCRIPTNAME {config|start|stop|start_redis|stop_redis|restart|deploy}" >&2  
        exit 2
        ;;  
esac  
