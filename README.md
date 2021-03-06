Sidekiq use with a Sinatra App
==============================

This demo tests Sidekiq for job processing with a Sinatra web app both under MRI Ruby and JRuby.

It also demonstrates how to build a WAR file from a Sinatra app that runs with an embedded Jetty server.
The Sidekiq worker(s) can also be run from the expanded WAR file without any dependency on having to
install JRuby on the target environment - you only need Java JDK 1.7.0.

Tested on Mac OS X 10.8.5 with a Centos 6.3 64-bit VM.

Prequisites:
------------

* VirtualBox [Tested with v4.3.6]
* Vagrant    [Tested with v1.4.0]
* Optional plugin: vagrant-cachier [Tested with v0.5.1]

Testing Sidekiq on MRI 1.9.3
----------------------------

Create and log onto the VM:

    vagrant up
    vagrant ssh

On the VM:

    sudo su
    source ~/.bash_profile
    cd /vagrant

Verify you are using MRI Ruby 1.9.3:

    ruby -v
    # ==> ruby 1.9.3p448 (2013-06-27 revision 41675) [x86_64-linux]

Run the Sinatra web app:

    bundle exec rackup

Test the web app is up by browsing to `http://localhost:49292` on your host machine.

You should see "Sinatra Demo App is alive!"

Try out the Sidekiq monitoring dashboard by browing to `http://localhost:49292/sidekiq` on your host machine.

Start a Sidekiq worker to process pending jobs in Redis:

    # Run this command on the VM
    ./process_jobs.sh

Generate some random numbers to be stored in a Redis list:
    
    # Run this command a few times on the VM (use port 49292 if running from your host machine)
    curl -X POST http://localhost:9292/numbers -d ''
    # ==> Your request to make a number is pending.
    curl -X POST http://localhost:9292/numbers -d ''
    # ==> Your request to make a number is pending.
    curl -X POST http://localhost:9292/numbers -d ''
    # ==> Your request to make a number is pending.

Get back the list of random numbers:

    # Run this command on the VM (use port 49292 if running from your host)
    curl http://localhost:9292/numbers
    # ==> Random numbers: 70, 42, 54

Have a look in Redis to see what's going on:

    # First stop the Sidekiq worker using CTRL-C.
    # Run this command on the VM to enter the Redis CLI:
    redis-cli

    # Type "keys *" to see all the available keys in Redis
    redis 127.0.0.1:6379> keys *
    1) "sidekiq_demo:stat:processed:2014-01-09"
    2) "sidekiq_demo:queue:default"
    3) "sidekiq_demo:stat:processed"
    4) "sidekiq_demo:queues"
    5) "random-numbers"

    # Let's see our currently queued job(s) without removing them
    # (requires stopping the Sidekiq workers then generating a new random number).
    > LRANGE sidekiq_demo:queue:default 0 -1
    1) "{\"retry\":true,\"queue\":\"default\",\"class\":\"RandomNumberWorker\",\"args\":[100],\"jid\":\"c70f3d594444040469538556\",\"enqueued_at\":1389305919.2538064}"

    # And let's see our current list of random numbers.
    redis 127.0.0.1:6379> LRANGE random-numbers 0 -1
    1) "54"    
    2) "42"
    3) "70"

    # Exit redis-cli with CTRL-D

Testing Sidekiq on JRuby 1.7.9
------------------------------

On the VM:

    sudo su
    source ~/.bash_profile
    cd /vagrant
    rbenv local jruby-1.7.9
    gem install bundler --no-ri --no-rdoc
    rbenv rehash
    bundle install
    rbenv rehash

Now we are using JRuby 1.7.9.

Follow the steps in `Testing Sidekiq on MRI 1.9.3` above to test out Sidekiq with Sinatra.

Building an executable WAR file (JRuby)
---------------------------------------

On the VM:

    sudo su
    source ~/.bash_profile
    cd /vagrant
    rbenv local jruby-1.7.9

    # Build the WAR file (see config/warble.rb for configuration)
    warble executable war
    # --> creates 'sidekiq-demo.war'

    # Run the web app
    java -jar sidekiq.war

Access the running web server on port 8080:

    curl -X POST http://localhost:8080/numbers -d ''

Starting Sidekiq workers from the expanded WAR.  This is need since Sidekiq needs to require a file to load the worker environment:

    ./process_jobs_war.sh
    curl http://localhost:8080/numbers


Further Info
------------

See the [SideKiq](http://sidekiq.org/) website for documentation and examples.
