EasyJobs
========

A simple SSH web interface to ease your workload.  
减轻你工作量的、简便的SSH网页界面

Please note that this repository is not being actively maintained.

You may want to use a newer similar project: [Maintainer](https://github.com/caiguanhao/Maintainer)

---

![easyjobs-3](https://f.cloud.github.com/assets/1284703/2059933/e410728e-8be9-11e3-8673-2be86fcbf2be.png)

[More screenshots](https://github.com/caiguanhao/EasyJobs/issues/1)

Features / Log
--------------

Since v0.1:

* Run commands or scripts via SSH.
* Custom interpreter besides ``/bin/bash``.
* Connect SSH via password or private key.
* Streaming output using HTML5 Server-Sent Events.
* Two factor authentication with Google Authenticator.
* Graphically showing time used each time running the script.

Since v0.2:

* Support output content in UTF-8 encoding.
* I18n support with English or Simplified Chinese translations.

Since v0.21:

* Add password, key and QR code protection and fix some problems.

Since v0.3

* Add API v1 and [Android](https://github.com/qnn/EasyJobs-android) support.

How to use
----------

### Job script variable

You can use variable if your script is using the **(default)** interpreter. For example, if your script contains:

    id %{user}

then you can enter the value to this variable (user) before you run the script.

### Interpreters

***(default)***

Take each line as separate command and commands will be executed **separately**:

    $ cd /srv
    $ pwd
      /root
    $ cd /srv && pwd
      /srv

If your command is too long for one line, you can break the line with a back-slash (\\) at the end of the line.

Lines starting with a hashtag (#) will be treated as comments and will not be executed. Do not add comments at the same line of the command.

For most systems, the interpreter for the login user is ``/bin/bash``.

***Common interpreters:***

* /bin/bash
* /usr/bin/perl
* /usr/bin/php
* /usr/bin/python
* /usr/bin/ruby

You can add interpreters that exist on remote server.

Note: Some interpreters don't support reading code from standard input but from file, like ``/bin/bash``. You need to check the *Upload script first* option to make it work. 

Configurations
--------------

Nginx:

    upstream EasyJobs_app {
      server unix:///srv/qnn/EasyJobs/tmp/sockets/puma.socket;
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

Rails:

    cd /srv/qnn
    git clone https://github.com/qnn/EasyJobs.git
    cd EasyJobs
    export RAILS_ENV=production
    sudo apt-get install libsqlite3-dev nodejs
    bundle
    rake db:migrate
    rake db:seed
    rake assets:precompile
    rake puma:start

Default admin can be found in ``db/seeds.rb``:

    Username: admin
    Password: 12345678

Get Google Authenticator code:

    rails c
    ROTP::TOTP.new(Admin.first.auth_secret).now.to_s.rjust(6,'0')

Puma
----

    rake puma:restart           # Restart Puma
    rake puma:start             # Start Puma
    rake puma:status            # Check Puma Status
    rake puma:stop              # Stop Puma

Gems used
---------

* turbolinks
* haml-rails
* puma
* net-scp (Net::SCP)
* net-ssh (Net::SSH)
* codemirror-rails
* devise
* rotp
* ...

JavaScript:

* highcharts.js
* jquery.qrcode.min.js
* ...

Requirements
------------

* Ruby 2.0.0
* Rails 4.0.0
* Browsers that support Server-Sent Events.
  * Most of the modern desktop or mobile web browser except Internet Explorer

License
-------

* [The BSD 3-Clause License](https://github.com/qnn/EasyJobs/blob/master/LICENSE)

See also
--------

* [EasyJobs Android Client](https://github.com/qnn/EasyJobs-android)
* [EasyJobs Android Client on Google Play](https://play.google.com/store/apps/details?id=com.cghio.easyjobs)

Developer
---------

* caiguanhao
