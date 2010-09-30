# Integrity: a continuous integration server for vLex

This repository contains a customisation of the integrity project to automatically run integrated tests against [vLex website](http://vlex.com).

## Characteristics

The [most relevant changes of this branch](http://github.com/vlex/integrity/compare/master...vlex), compared to integrity/integrity are:

 * xvfb and selenium are executed on startup, so that tests written in [selenium](http://seleniumhq.org/) can be run, even on machines with no GUI
 * bundler08 is used instead of [bundler](http://gembundler.com/), which does not work well with the current versions of passenger and sinatra
 * threads are managed with delayed_job and rake jobs:work is executed on startup, since ruby threader tends to get stuck with many instances
 * e-mails notifications are active

Moreover, this branch includes visual changes inherited from the [enhanced](http://github.com/vlex/integrity/tree/enhanced) branch:

 * wider output, occupying 90% of the page rather than just 40em
 * elapsed time for each build shown in the list of builds
 * output of the build processes shown **in real time**, not just at the end of each build
 * screenshots taken on failed tests shown within each build
 * pending builds styled in yellow, rather than in red/grey


## Install

This code is currently up and running on [integrity.vlex.com](http://integrity.vlex.com) (requires authentication), and can be installed on any other server by following these instructions.

### Set up the machine (run all these commands as _root_):

Create a new instance of an Amazon EC2 medium server running Ubuntu.

Install apache:

    aptitude install apache2-mpm-worker apache2-prefork-dev apache2-utils

Install X virtual framebuffer (to run Firefox without GUI):

    aptitude install xorg xserver-org xvfb xinit x11-xkb-utils xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic

Install Firefox 2:

    wget http://mirrors.kernel.org/ubuntu/pool/main/h/hunspell/libhunspell-1.1-0_1.1.9-1_i386.deb
    wget http://security.ubuntu.com/ubuntu/pool/universe/f/firefox/firefox-2_2.0.0.21~tb.21.308+nobinonly-0ubuntu0.8.04.1_i386.deb
    dpkg -i libhunspell-1.1-0_1.1.9-1_i386.deb
    dpkg -i firefox-2_2.0.0.21~tb.21.308+nobinonly-0ubuntu0.8.04.1_i386.deb

Firefox 2 is required since Firefox 3 does not work properly with our configuration of Selenium/Webrat (while it would with [Capybara](http://github.com/jnicklas/capybara)). 
Also, webrat expects to find the Firefox executable at firefox-bin, so create the appropriate symlink:

    ln -s /usr/lib/firefox/firefox-2-bin /usr/lib/firefox/firefox-bin

Install Ruby and Rubygems:

    aptitude install ruby1.8 ruby1.8-dev rubygems1.8

Install Passenger:

    gem install passenger -v 2.2.9
    passenger-install-apache2-module

Create an integrity user that will run the application:

    adduser integrity

Set this user, the application local folder, HTTP Basic authentication and other options in the Apache config file `/etc/apache2/sites-enabled/000-default` as follows:

    LoadModule passenger_module /var/lib/gems/1.8/gems/passenger-2.2.9/ext/apache2/mod_passenger.so
    PassengerRoot /var/lib/gems/1.8/gems/passenger-2.2.9
    PassengerRuby /usr/bin/ruby1.8
    ServerAdmin admin@example.com
    <VirtualHost *:80>
    PassengerPoolIdleTime 3000
    PassengerDefaultUser integrity
    DocumentRoot **YOUR_APP_ROOT**/public
    <Location "/">
    AllowOverride All
    Options FollowSymLinks -Includes
    Order allow,deny
    Allow from all
    AuthUserFile /home/integrity/.devels_htpasswd
    AuthName "**YOUR_APP_URL**"
    AuthType Basic
    <Limit GET POST>
    require valid-user
    </Limit>
    <Limit CONNECT>
    Order Deny,Allow
    Deny from all
    </Limit>
    </Location>
    SetEnv PATH /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
    ErrorLog /var/log/apache2/error.log
    LogLevel warn
    CustomLog /var/log/apache2/access.log combined
    </VirtualHost>

Install libraries required by [webrat](http://github.com/brynary/webrat):

    aptitude install libxslt-dev libxml12-dev

Install libraries required by [selenium](http://selenium-client.rubyforge.org)

    aptitude install sun-java6-jre

Install libraries required by [integrity](http://github.com/integrity/integrity)

    aptitude install sqlite3 git-core

### Set up integrity (run all these commands as _integrity_):

Edit `~/.profile` to install gem locally and to `cd` to the application folder:

    export PATH="$HOME/.gem/ruby/1.8/bin:$PATH"
    export GEM_PATH="$HOME/.gem/ruby/1.8"
    export GEM_HOME="$HOME/.gem/ruby/1.8"
    cd "**YOUR_APP_ROOT**"

Run `source ~/.profile`, then download the integrity repository from GitHub:

    git clone git://github.com/vlex/integrity.git

Install bundler08 (newer versions have problems with passenger) and bundle gems:

    gem install bundler08
    gem bundle

Create the integrity database:

    rake db

Restart the application:

    touch tmp/restart.txt

The [restart script](http://github.com/vlex/integrity/blob/vlex/config.ru) will automatically open an instance of the virtual frame buffer, selenium and starts the delayed jobs worker, so the application will be up and running whenever the server is restarted.

### To do:

* Create a cacti alert to monitor the disk space. If needed, add a cron to periodically remove builds/ subfolders and to rotate the log files generated by integrity and selenium.

* Consider [Selenium Grid](http://selenium-grid.seleniumhq.org/) to speed up tests by running Selenium on multiple machines
