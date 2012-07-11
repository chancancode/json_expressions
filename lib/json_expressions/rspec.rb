require 'rspec'
require 'json_expressions'
require 'json_expressions/rspec/matchers'

RSpec::configure do |config|
  config.include(JsonExpressions::RSpec::Matchers)
end