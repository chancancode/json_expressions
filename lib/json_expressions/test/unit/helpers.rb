require 'json'
require 'pp'

module JsonExpressions
  module Test
    module Unit
      module Helpers
        def assert_json_match(exp, act, msg = nil)
          unless JsonExpressions::Matcher === exp
            exp = JsonExpressions::Matcher.new(exp)
          end

          if String === act
            begin
              act = JSON.parse(act)
            rescue
              assert false, "Expected #{pp(act)} to be valid JSON"
            end
          end

          assert exp =~ act, ->{ "Expected #{pp(exp)} to match #{pp(act)}\n" + exp.last_error}

          # Return the matcher
          return exp
        end
      end
    end
  end
end