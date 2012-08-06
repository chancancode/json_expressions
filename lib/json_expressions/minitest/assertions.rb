require 'json'

module MiniTest
  module Assertions
    def assert_json_match(exp, act, msg = nil)
      unless JsonExpressions::Matcher === exp
        exp = JsonExpressions::Matcher.new(exp)
      end

      if String === act
        assert act = JSON.parse(act), "Expected #{mu_pp(act)} to be valid JSON"
      end

      assert exp =~ act, ->{ "Expected #{mu_pp(exp)} to match #{mu_pp(act)}\n" + exp.last_error}

      # Return the matcher
      return exp
    end

    def refute_json_match(exp, act, msg = nil)
      unless JsonExpressions::Matcher === exp
        exp = JsonExpressions::Matcher.new(exp)
      end

      if String === act
        assert act = JSON.parse(act), "Expected #{mu_pp(act)} to be valid JSON"
      end

      refute exp =~ act, "Expected #{mu_pp(exp)} to not match #{mu_pp(act)}"

      # Return the matcher
      return exp
    end
  end
end
