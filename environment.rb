require 'mongo_mapper'
require 'pry'
require 'csv'
require 'nokogiri'
require 'json'
require 'rest_client'
require 'tweetstream'
require 'twitter'
require 'sinatra'
require 'sidekiq'

Dir[File.dirname(__FILE__) + '/extensions/*.rb'].each {|file| require file }
require_relative File.dirname(__FILE__) + '/lib/transactor.rb'
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/lib/graph/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/workers/*.rb'].each {|file| require file }
MongoMapper.connection = Mongo::MongoClient.new(:pool_size => 25, :pool_timeout => 60)
MongoMapper.database = "listserv_scraper"

Sidekiq.configure_client do |config|
  config.redis = { :size => 1 }
end

