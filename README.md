EasyJobs
========

A simple SSH web interface to ease your workload.

Features
--------

* Run commands or scripts via SSH.
* Custom interpreter besides ``/bin/bash``.
* Connect SSH via password or private key.
* Streaming output using HTML5 Server-Sent Events.
* Two factor authentication with Google Authenticator.
* Graphically showing time used each time running the script.

How to use
----------

Nginx config:

    upstream EasyJobs_app {
      server unix:/tmp/EasyJobsApp.puma.sock;
    }

    server {
      listen 80;
      server_name <SERVER_NAME>;
      client_max_body_size 10m;
      keepalive_timeout 60;
      root /srv/qnn/EasyJobs/public;
      access_log /srv/qnn/EasyJobs/log/production.access.log;
      error_log /srv/qnn/EasyJobs/log/production.error.log info;
      error_page 500 502 503 504 /500.html;
      location = /500.html {
        root /srv/qnn/EasyJobs/public;
      }
      try_files $uri/index.html $uri.html $uri @app;
      location @app {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://EasyJobs_app;
        proxy_buffering off;
        proxy_cache off;
        proxy_set_header Connection '';
        proxy_http_version 1.1;
        chunked_transfer_encoding off;
      }
    }

Deploy:

    cd /srv/qnn
    git clone https://github.com/qnn/EasyJobs.git
    cd EasyJobs
    export RAILS_ENV=production
    bundle
    bundle exec rake db:migrate
    bundle exec rake db:seed
    bundle exec rake assets:precompile
    puma -e production -b unix:/tmp/EasyJobsApp.puma.sock

Requirements
------------

* Ruby 2.0.0
* Rails 4.0.0

License
-------

* [The BSD 3-Clause License](https://github.com/qnn/EasyJobs/blob/master/LICENSE)

Developer
---------

* caiguanhao
