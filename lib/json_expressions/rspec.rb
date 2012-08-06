require 'rspec'
require 'json_expressions'
require 'json_expressions/rspec/matchers'

RSpec::configure do |config|
  config.include(JsonExpressions::RSpec::Matchers)
end

module RSpec
  module Core
    class ExampleGroup
      def wildcard_matcher
        ::JsonExpressions::WILDCARD_MATCHER
      end
    end
  end
end