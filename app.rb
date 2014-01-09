require 'bundler/setup'
Bundler.require(:default)

require 'sinatra/base'
require 'sidekiq'
require 'redis'
require_relative 'random_number_worker'

class App < Sinatra::Base

	configure do
		Sidekiq.configure_client do |config|
			config.redis = { :namespace => 'sidekiq_demo', :url => 'redis://localhost:6379' }
		end
	end

	get '/' do
		"Sinatra Demo App is alive!"
	end

	get '/numbers' do
		numbers = redis.lrange("random-numbers", 0, -1)
		status 200
		if numbers.count > 0
			msg = "Random numbers: #{numbers.reverse.join(', ')}"
		else
			msg = "Create some numbers by POSTing to /numbers first."
		end
		body msg
	end

	post '/numbers' do
		RandomNumberWorker.perform_async(100)
		status 202
		body "Your request to make a number is pending."
	end

	def redis
		@redis ||= Redis.new
	end
end	
