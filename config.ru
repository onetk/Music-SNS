require 'bundler'
Bundler.require
require "rubygems"
require './app'

config_file './config.yml'

Cloudinary.config do |config|
  config.cloud_name = settings.cloud_name
  config.api_key = settings.api_key
  config.api_secret = settings.api_secret
end

run Sinatra::Application
