#!/bin/sh

echo "Starting Sidekiq workers..."
bundle exec sidekiq -r ./workers.rb -vvv
