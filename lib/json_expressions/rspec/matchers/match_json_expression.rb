require 'json'
require 'rspec/core'

module JsonExpressions
  module RSpec
    module Matchers
      class MatchJsonExpression
        def initialize(expected)
          if JsonExpressions::Matcher === expected
            @expected = expected
          else
            @expected = JsonExpressions::Matcher.new(expected)
          end
        end

        def matches?(target)
          @target = (String === target) ? JSON.parse(target) : target
          @expected =~ @target
        end
        alias_method :===, :matches?

        def failure_message_for_should
          "expected #{@target.inspect} to match JSON expression #{@expected.inspect}\n" + @expected.last_error
        end
        alias_method :failure_message, :failure_message_for_should

        def failure_message_for_should_not
          "expected #{@target.inspect} not to match JSON expression #{@expected.inspect}"
        end
        alias_method :failure_message_when_negated, :failure_message_for_should_not

        def description
          "should equal JSON expression #{@expected.inspect}"
        end
      end

      def match_json_expression(expected)
        MatchJsonExpression.new(expected)
      end
    end
  end
end
