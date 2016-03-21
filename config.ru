puts '~~~~!!THIS IS SPYDEER!!~~~~'

require 'sinatra'
require 'sequel'
require 'yaml'
require 'tilt/erb'
#require 'json'
require 'rufus-scheduler'


CONFIG =  YAML.load_file('config.yml')

use Rack::Session::Cookie, :secret => CONFIG['cookie_secret']

require './models.rb'
require './app.rb'

run Spydeer
