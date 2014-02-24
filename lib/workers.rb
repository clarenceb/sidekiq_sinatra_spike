require 'sidekiq'

begin
  puts 'Starting workers...'
    
  Sidekiq.configure_server do |config|
    config.redis = { :namespace => 'sidekiq_demo', :url => 'redis://localhost:6379' }
  end

  require_relative 'random_number_worker'
  puts 'Ready.'
rescue => e
  $stderr.puts "Error: #{e.message}"
end
