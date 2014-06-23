$:.unshift 'lib'
require 'logger'
require 'rack/conditionalget'
require 'texrack'

Texrack.config[:cache_dir] = File.join(File.dirname(__FILE__), 'tmp', 'cache')
Texrack.config[:logger]    = Logger.new('log/texrack.log')

use Rack::ConditionalGet
run Texrack::Endpoint.new
