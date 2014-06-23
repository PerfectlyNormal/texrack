$:.unshift 'lib'
require 'rack/conditionalget'
require 'texrack'

use Rack::ConditionalGet
run Texrack::Endpoint.new
