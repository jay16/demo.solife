# [Personal Demo]

## start up

````
rbenv local your-ruby-version
./unicorn {start|stop|restart|force-reload|deploy}

bundle exec rake remote:deploy
````

## TODO

  1. deal with weixin#voice(media_id, format, recogination)


## UPDATE

  1. different domain mapping different route when point to /demo.

    demo.solife.us/hello => demo.solife.us/demo/hello
    
    demo.solife.us/demo/hello => demo.solife.us/demo/hello

    nginx cofiguration:

    ````
    upstream solife-demo-unicorn {
       server unix:/app-root-path/tmp/unicorn.sock fail_timeout=0;
    }
  	server {
      listen 80;
      server_name weixin.solife.us;
      root app-root-path/public;

      location / {
        try_files $uri @net;
      }
      location @net {
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $http_host;
          proxy_redirect off;
          proxy_pass http://solife-demo-unicorn;
      }
    }
   server {
      listen 80;
      server_name demo.solife.us;
      root app-root-path/public;

      location / {
        try_files $uri @net;
       }
      location @net {
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $http_host;
          proxy_redirect off;
          proxy_pass http://solife-demo-unicorn ;
      }

	  # point
      if ($request_uri !~* "^/demo") {
        rewrite ^/(.*)$ /demo/$1;
      }
    }
    ````

