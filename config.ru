puts '~~~~!!THIS IS SPYDER!!~~~~'

require 'sinatra'
require 'sequel'
require 'yaml'
require 'tilt/erb'
#require 'json'

#CONFIG =  YAML.load_file('config.yml')

#use Rack::Session::Cookie, :secret => CONFIG['cookie_secret']

require './app.rb'

run Spyder
