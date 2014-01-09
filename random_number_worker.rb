require 'sidekiq'
require 'redis'

class RandomNumberWorker

	include Sidekiq::Worker

	def perform(max_number)
		logger.info "Generating a random number..."
		number = rand(max_number) + 1
		logger.info "Your number is #{number}."
		store_number_in_redis_list(number)
	end

	private

	def store_number_in_redis_list(number)
		redis = Redis.new
		redis.lpush("random-numbers", number)
	end

end
