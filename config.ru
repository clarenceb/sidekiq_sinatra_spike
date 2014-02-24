require './lib/app'
require 'sidekiq/web'

run Rack::URLMap.new('/' => App, '/sidekiq' => Sidekiq::Web)
