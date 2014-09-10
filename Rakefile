load 'environment.rb'
task :run_crawl do
  Crawler.perform_async(ENV['LISTSERV'])
end

task :monitor do
  require 'sidekiq/web'
  app = Sidekiq::Web
  app.set :environment, :production
  app.set :bind, '0.0.0.0'
  app.set :port, 9494
  app.set :server, :webrick
  app.run!
end
